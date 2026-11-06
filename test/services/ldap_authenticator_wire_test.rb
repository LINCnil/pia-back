require 'test_helper'
require 'active_support/testing/constant_stubbing'
require 'tempfile'

class LdapAuthenticatorWireTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::ConstantStubbing

  class LdapServer
    BASE = 'ou=people,dc=example,dc=test'
    USER_DN = "uid=alice,#{BASE}"
    USER_PASSWORD = 'ldap-secret'
    ADMIN_DN = 'cn=admin,dc=example,dc=test'
    ADMIN_PASSWORD = 'admin-secret'

    REQUEST_SYNTAX = Net::BER.compile_syntax(
      application: { constructed: { 0 => :array, 3 => :array, 23 => :array }, primitive: { 2 => :null } },
      context_specific: { constructed: { 3 => :array, 4 => :array }, primitive: { 0 => :string, 7 => :string } }
    )

    attr_reader :port, :binds, :filters

    def initialize(tls: nil, certificate: nil, key: nil, expect_tls_failure: false, delay_search: 0)
      @listener = TCPServer.new('127.0.0.1', 0)
      @port = @listener.addr[1]
      @binds = []
      @filters = []
      @tls = tls
      @expect_tls_failure = expect_tls_failure
      @delay_search = delay_search
      if tls
        @tls_context = OpenSSL::SSL::SSLContext.new
        @tls_context.cert = certificate
        @tls_context.key = key
      end
      @thread = Thread.new { serve }
      @thread.report_on_exception = false
    end

    def close
      @closed = true
      @listener.close unless @listener.closed?
      @socket.close if @socket && !@socket.closed?
      raise 'LDAP test server did not stop' unless @thread.join(3)

      @thread.value
    end

    private

    def serve
      @socket = @listener.accept
      @socket = tls_socket(@socket) if @tls == :simple_tls
      while (message = @socket.read_ber(REQUEST_SYNTAX))
        id, request = message
        case request.ber_identifier
        when 0x60
          handle_bind(id, request)
        when 0x63
          handle_search(id, request)
        when 0x77
          raise 'Unexpected StartTLS request' unless @tls == :start_tls

          write_result(id, 24, 0)
          @socket = tls_socket(@socket)
        else
          raise "Unexpected LDAP request #{request.ber_identifier}"
        end
      end
    rescue OpenSSL::SSL::SSLError
      raise unless @expect_tls_failure || @closed
    rescue IOError
      raise unless @closed
    ensure
      @socket.close if @socket && !@socket.closed?
    end

    def tls_socket(socket)
      ssl = OpenSSL::SSL::SSLSocket.new(socket, @tls_context)
      ssl.sync_close = true
      ssl.extend(Net::LDAP::Connection::GetbyteForSSLSocket) unless ssl.respond_to?(:getbyte)
      ssl.accept
      ssl
    end

    def handle_bind(id, request)
      username = request[1].to_s
      password = request[2].to_s
      @binds << [username, password]
      valid = [username, password] == ['', ''] ||
              [username, password] == [USER_DN, USER_PASSWORD] ||
              [username, password] == [ADMIN_DN, ADMIN_PASSWORD]
      write_result(id, 1, valid ? 0 : Net::LDAP::ResultCodeInvalidCredentials)
    end

    def handle_search(id, request)
      filter = request[6]
      @filters << [filter.ber_identifier, *Array(filter)]
      sleep @delay_search if @delay_search.positive?
      if filter.ber_identifier == 0xa3 && filter[0] == 'uid' && filter[1] == 'alice'
        mail = ['mail'.to_ber, ['alice@example.test'.to_ber].to_ber_set].to_ber_sequence
        entry = [USER_DN.to_ber, [mail].to_ber_sequence].to_ber_appsequence(4)
        @socket.write([id.to_ber, entry].to_ber_sequence)
      end
      write_result(id, 5, 0)
    end

    def write_result(id, operation, code)
      result = [code.to_ber_enumerated, ''.to_ber, ''.to_ber].to_ber_appsequence(operation)
      @socket.write([id.to_ber, result].to_ber_sequence)
    end
  end

  test 'searches anonymously and binds as the user over a real LDAP connection' do
    with_server do |server|
      result = authenticator(server).authenticate('alice', LdapServer::USER_PASSWORD)

      assert_equal 'alice@example.test', result.email
      assert_equal [['', ''], [LdapServer::USER_DN, LdapServer::USER_PASSWORD]], server.binds
      assert_equal [[0xa3, 'uid', 'alice']], server.filters
    end
  end

  test 'searches with admin credentials over a real LDAP connection' do
    with_server do |server|
      result = authenticator(server, use_admin: true).authenticate('alice', LdapServer::USER_PASSWORD)

      assert_equal 'alice@example.test', result.email
      assert_equal [LdapServer::ADMIN_DN, LdapServer::ADMIN_PASSWORD], server.binds.first
      assert_equal [LdapServer::USER_DN, LdapServer::USER_PASSWORD], server.binds.last
    end
  end

  test 'treats a wildcard login as a literal LDAP equality filter' do
    with_server do |server|
      assert_nil authenticator(server).authenticate('*', LdapServer::USER_PASSWORD)
      assert_equal [[0xa3, 'uid', '*']], server.filters
    end
  end

  test 'rejects a wrong password over a real LDAP connection' do
    with_server do |server|
      assert_nil authenticator(server).authenticate('alice', 'wrong-password')
    end
  end

  test 'issues an OAuth token after a real LDAP authentication' do
    previous_value = ENV['DEVISE_LDAP_LOGGER']
    with_server do |server|
      application = Doorkeeper::Application.create!(
        name: 'LDAP wire test client',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        scopes: 'read write'
      )
      config = ldap_config(server)
      configured_authenticator = Class.new(LdapAuthenticator) do
        define_method(:initialize) { super(config: config, use_admin: false) }
      end
      session = ActionDispatch::Integration::Session.new(Rails.application)
      ENV['DEVISE_LDAP_LOGGER'] = 'true'

      stub_const(Object, :LdapAuthenticator, configured_authenticator) do
        session.post '/oauth/token', params: {
          grant_type: 'password',
          email: 'alice',
          password: LdapServer::USER_PASSWORD,
          client_id: application.uid,
          client_secret: application.secret
        }
      end

      assert_equal 200, session.response.status
      token = Doorkeeper::AccessToken.find_by!(token: session.response.parsed_body.fetch('access_token'))
      assert_equal User.find_by!(login: 'alice').id, token.resource_owner_id
      assert_equal 'alice@example.test', User.find_by!(login: 'alice').email
    end
  ensure
    previous_value.nil? ? ENV.delete('DEVISE_LDAP_LOGGER') : ENV['DEVISE_LDAP_LOGGER'] = previous_value
  end

  test 'times out when the directory does not answer a search' do
    with_server(delay_search: 1.5) do |server|
      stub_const(LdapAuthenticator, :REQUEST_TIMEOUT, 1) do
        error = assert_raises(LdapAuthenticator::Error) do
          authenticator(server).authenticate('alice', LdapServer::USER_PASSWORD)
        end
        assert_instance_of Timeout::Error, error.cause
        assert_equal [[0xa3, 'uid', 'alice']], server.filters
      end
    end
  end

  test 'accepts a trusted matching certificate for LDAPS and StartTLS' do
    with_certificate do |certificate, key, ca_file|
      %i[simple_tls start_tls].each do |method|
        with_server(tls: method, certificate: certificate, key: key) do |server|
          config = { host: 'localhost', encryption: { method: method, tls_options: { ca_file: ca_file } } }
          result = authenticator(server, config: config).authenticate('alice', LdapServer::USER_PASSWORD)

          assert_equal 'alice@example.test', result.email
        end
      end
    end
  end

  test 'rejects an untrusted LDAP server certificate' do
    with_certificate do |certificate, key, _ca_file|
      %i[simple_tls start_tls].each do |method|
        with_server(tls: method, certificate: certificate, key: key, expect_tls_failure: true) do |server|
          config = { host: 'localhost', ssl: method.to_s }
          error = assert_raises(LdapAuthenticator::Error) do
            authenticator(server, config: config).authenticate('alice', LdapServer::USER_PASSWORD)
          end
          assert_match(/certificate verify failed/i, error.cause.message)
          assert_match(/TLS certificate verification failed.*encryption\.tls_options\.ca_file/, error.message)
        end
      end
    end
  end

  test 'rejects a trusted LDAP certificate for a different hostname' do
    with_certificate do |certificate, key, ca_file|
      %i[simple_tls start_tls].each do |method|
        with_server(tls: method, certificate: certificate, key: key, expect_tls_failure: true) do |server|
          config = { encryption: { method: method, tls_options: { ca_file: ca_file } } }
          error = assert_raises(LdapAuthenticator::Error) do
            authenticator(server, config: config).authenticate('alice', LdapServer::USER_PASSWORD)
          end
          assert_match(/hostname/i, error.cause.message)
          assert_match(/TLS certificate verification failed/, error.message)
        end
      end
    end
  end

  test 'accepts an untrusted certificate for another hostname when verification is explicitly disabled' do
    with_certificate do |certificate, key, _ca_file|
      %i[simple_tls start_tls].each do |method|
        with_server(tls: method, certificate: certificate, key: key) do |server|
          config = { encryption: { method: method, verify_certificates: false } }
          result = nil
          capture_io { result = authenticator(server, config: config).authenticate('alice', LdapServer::USER_PASSWORD) }

          assert_equal 'alice@example.test', result.email
        end
      end
    end
  end

  private

  def authenticator(server, use_admin: false, config: {})
    LdapAuthenticator.new(config: ldap_config(server).merge(config), use_admin: use_admin)
  end

  def ldap_config(server)
    {
      host: '127.0.0.1',
      port: server.port,
      attribute: 'uid',
      base: LdapServer::BASE,
      admin_user: LdapServer::ADMIN_DN,
      admin_password: LdapServer::ADMIN_PASSWORD,
      ssl: false
    }
  end

  def with_server(**options)
    server = LdapServer.new(**options)
    yield server
  ensure
    server&.close
  end

  def with_certificate
    key = OpenSSL::PKey::RSA.new(2048)
    certificate = OpenSSL::X509::Certificate.new
    certificate.version = 2
    certificate.serial = 1
    certificate.subject = certificate.issuer = OpenSSL::X509::Name.parse('/CN=localhost')
    certificate.public_key = key.public_key
    certificate.not_before = Time.now - 60
    certificate.not_after = Time.now + 3600
    extensions = OpenSSL::X509::ExtensionFactory.new
    extensions.subject_certificate = certificate
    extensions.issuer_certificate = certificate
    certificate.add_extension(extensions.create_extension('basicConstraints', 'CA:TRUE', true))
    certificate.add_extension(extensions.create_extension('keyUsage', 'digitalSignature,keyEncipherment,keyCertSign', true))
    certificate.add_extension(extensions.create_extension('subjectAltName', 'DNS:localhost'))
    certificate.sign(key, OpenSSL::Digest.new('SHA256'))

    Tempfile.create(['ldap-ca', '.pem']) do |file|
      file.write(certificate.to_pem)
      file.flush
      yield certificate, key, file.path
    end
  end
end
