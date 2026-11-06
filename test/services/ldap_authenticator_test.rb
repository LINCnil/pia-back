require 'test_helper'

class LdapAuthenticatorTest < ActiveSupport::TestCase
  class FakeConnection
    Result = Struct.new(:code, :error_message)

    attr_accessor :initial_code, :search_code, :search_message, :bind_code, :entries, :open_error
    attr_reader :search_options, :bind_options

    def initialize
      @initial_code = Net::LDAP::ResultCodeSuccess
      @search_code = Net::LDAP::ResultCodeSuccess
      @bind_code = Net::LDAP::ResultCodeSuccess
      @entries = []
    end

    def open
      raise open_error if open_error

      @result_code = initial_code
      yield self
    end

    def search(**options)
      @search_options = options
      @result_code = search_code
      @result_message = search_message
      entries
    end

    def bind(**options)
      @bind_options = options
      @result_code = bind_code
      bind_code == Net::LDAP::ResultCodeSuccess
    end

    def get_operation_result
      Result.new(@result_code, @result_message)
    end
  end

  class FakeFactory
    attr_reader :options

    def initialize(connection)
      @connection = connection
    end

    def new(options)
      @options = options
      @connection
    end
  end

  setup do
    @config = {
      host: 'ldap.example.test',
      port: 636,
      attribute: 'uid',
      base: 'ou=people,dc=example,dc=test',
      admin_user: 'cn=admin,dc=example,dc=test',
      admin_password: 'admin-secret',
      ssl: 'simple_tls'
    }
    @entry = Net::LDAP::Entry.new('uid=alice,ou=people,dc=example,dc=test')
    @entry[:mail] = ['alice@example.test']
    @connection = FakeConnection.new
    @connection.entries = [@entry]
    @factory = FakeFactory.new(@connection)
  end

  test 'authenticates with the searched DN and returns the LDAP email' do
    result = authenticate

    assert_equal 'alice@example.test', result.email
    assert_equal({ method: :simple, username: @entry.dn, password: 'user-secret' }, @connection.bind_options)
    assert_equal '(uid=alice)', @connection.search_options[:filter].to_s
    assert_equal ['mail'], @connection.search_options[:attributes]
    assert_equal 2, @connection.search_options[:size]
    assert_equal LdapAuthenticator::CONNECT_TIMEOUT, @connection.search_options[:time]
    assert @connection.search_options[:ignore_server_caps]
    assert_equal LdapAuthenticator::CONNECT_TIMEOUT, @factory.options[:connect_timeout]
  end

  test 'uses admin credentials only when admin binding is enabled' do
    authenticate(use_admin: true)

    assert_equal(
      { method: :simple, username: @config[:admin_user], password: @config[:admin_password] },
      @factory.options[:auth]
    )
  end

  test 'uses anonymous searches when admin binding is disabled' do
    authenticate

    assert_not @factory.options.key?(:auth)
  end

  test 'preserves the legacy admin environment variable semantics' do
    previous_value = ENV.delete('DEVISE_LDAP_LOGGER_ADMIN_BIND')
    LdapAuthenticator.new(config: @config, ldap_factory: @factory).authenticate('alice', 'user-secret')
    assert_not @factory.options.key?(:auth)

    ['', 'false'].each do |value|
      ENV['DEVISE_LDAP_LOGGER_ADMIN_BIND'] = value
      LdapAuthenticator.new(config: @config, ldap_factory: @factory).authenticate('alice', 'user-secret')
      assert_equal @config[:admin_user], @factory.options[:auth][:username]
    end
  ensure
    if previous_value.nil?
      ENV.delete('DEVISE_LDAP_LOGGER_ADMIN_BIND')
    else
      ENV['DEVISE_LDAP_LOGGER_ADMIN_BIND'] = previous_value
    end
  end

  test 'enforces certificate and hostname verification for both TLS modes' do
    [true, 'simple_tls', 'start_tls'].each do |ssl|
      authenticate(config: @config.merge(ssl: ssl))

      expected_method = ssl == 'start_tls' ? :start_tls : :simple_tls
      assert_equal expected_method, @factory.options[:encryption][:method]
      assert_equal OpenSSL::SSL::VERIFY_PEER, @factory.options[:encryption][:tls_options][:verify_mode]
      assert_equal true, @factory.options[:encryption][:tls_options][:verify_hostname]
    end
  end

  test 'keeps custom CA settings and ignores verification overrides in tls_options' do
    encryption = {
      method: 'start_tls',
      tls_options: { ca_file: '/certificates/ldap-ca.pem', verify_mode: OpenSSL::SSL::VERIFY_NONE,
                     verify_hostname: false }
    }
    authenticate(config: @config.merge(encryption: encryption))

    options = @factory.options[:encryption]
    assert_equal :start_tls, options[:method]
    assert_equal '/certificates/ldap-ca.pem', options[:tls_options][:ca_file]
    assert_equal OpenSSL::SSL::VERIFY_PEER, options[:tls_options][:verify_mode]
    assert_equal true, options[:tls_options][:verify_hostname]
  end

  test 'disables certificate and hostname verification only with verify_certificates false' do
    encryption = { method: 'start_tls', verify_certificates: false, tls_options: { ca_file: '/certificates/ldap-ca.pem' } }

    output = capture_logs { authenticate(config: @config.merge(encryption: encryption)) }

    options = @factory.options[:encryption]
    assert_equal :start_tls, options[:method]
    assert_equal OpenSSL::SSL::VERIFY_NONE, options[:tls_options][:verify_mode]
    assert_equal false, options[:tls_options][:verify_hostname]
    assert_includes output, 'LDAP TLS certificate and hostname verification is disabled'
  end

  test 'keeps verification enabled and silent when verify_certificates is true or unset' do
    [true, nil].each do |verify|
      output = capture_logs do
        authenticate(config: @config.merge(encryption: { method: 'simple_tls', verify_certificates: verify }))
      end

      assert_equal OpenSSL::SSL::VERIFY_PEER, @factory.options[:encryption][:tls_options][:verify_mode]
      assert_equal true, @factory.options[:encryption][:tls_options][:verify_hostname]
      assert_not_includes output, 'verification is disabled'
    end
  end

  test 'rejects a verify_certificates value that is not a boolean' do
    ['false', 'no', 0].each do |verify|
      error = assert_raises(LdapAuthenticator::Error) do
        authenticate(config: @config.merge(encryption: { method: 'simple_tls', verify_certificates: verify }))
      end

      assert_match 'verify_certificates must be true or false', error.message
    end
  end

  test 'allows legacy plaintext configuration without silently enabling TLS' do
    authenticate(config: @config.merge(ssl: false))

    assert_not @factory.options.key?(:encryption)
  end

  test 'rejects invalid TLS configuration' do
    error = assert_raises(LdapAuthenticator::Error) { authenticate(config: @config.merge(ssl: 'unknown')) }

    assert_match 'simple_tls or start_tls', error.message
  end

  test 'rejects missing credentials before connecting' do
    [[nil, 'secret'], ['', 'secret'], ["alice\0", 'secret'], ['alice', nil],
     ['alice', ''], ['alice', '   '], [{}, 'secret'], ['alice', {}]].each do |login, password|
      assert_nil authenticate(login: login, password: password)
    end
    assert_nil @factory.options
  end

  test 'escapes LDAP filter metacharacters in the login' do
    authenticate(login: '*)(uid=*)')

    assert_equal '(uid=\2A\29\28uid=\2A\29)', @connection.search_options[:filter].to_s
  end

  test 'constructs an escaped DN when a user is not found' do
    @connection.entries = []

    result = authenticate(login: 'smith,dc=other')

    assert_nil result.email
    assert_equal 'uid=smith\,dc=other,ou=people,dc=example,dc=test', @connection.bind_options[:username]
  end

  test 'uses the legacy DN when an admin search finds no user' do
    @connection.entries = []

    assert authenticate(use_admin: true)
    assert_equal @entry.dn, @connection.bind_options[:username]
  end

  test 'uses the legacy DN when anonymous search is denied' do
    @connection.entries = nil
    @connection.search_code = Net::LDAP::ResultCodeInsufficientAccessRights

    assert authenticate
    assert_equal @entry.dn, @connection.bind_options[:username]
  end

  test 'uses the legacy DN for the Active Directory anonymous search error' do
    @connection.entries = nil
    @connection.search_code = Net::LDAP::ResultCodeOperationsError
    @connection.search_message = 'In order to perform this operation a successful bind must be completed on the connection.'

    assert authenticate
    assert_equal @entry.dn, @connection.bind_options[:username]
  end

  test 'surfaces other anonymous search operation errors' do
    @connection.entries = nil
    @connection.search_code = Net::LDAP::ResultCodeOperationsError
    @connection.search_message = 'The directory operation failed'

    error = assert_raises(LdapAuthenticator::Error) { authenticate }
    assert_match 'search failed', error.message
    assert_nil @connection.bind_options
  end

  test 'uses the legacy DN when anonymous binding is denied' do
    @connection.initial_code = Net::LDAP::ResultCodeInappropriateAuthentication

    assert authenticate
    assert_nil @connection.search_options
    assert_equal @entry.dn, @connection.bind_options[:username]
  end

  test 'treats any refused user bind as invalid credentials' do
    [
      Net::LDAP::ResultCodeInvalidCredentials,
      Net::LDAP::ResultCodeNoSuchObject,
      Net::LDAP::ResultCodeInappropriateAuthentication,
      Net::LDAP::ResultCodeInvalidDNSyntax,
      Net::LDAP::ResultCodeConstraintViolation,
      Net::LDAP::ResultCodeUnwillingToPerform,
      Net::LDAP::ResultCodeBusy
    ].each do |code|
      @connection.bind_code = code
      assert_nil authenticate
    end
  end

  test 'logs the result code of a refused user bind without credentials' do
    @connection.bind_code = Net::LDAP::ResultCodeConstraintViolation

    output = capture_logs { assert_nil authenticate }

    assert_includes output, 'LDAP user bind refused (result code 19)'
    assert_not_includes output, 'user-secret'
    assert_not_includes output, 'alice'
  end

  test 'does not treat failed admin authentication as invalid user credentials' do
    @connection.initial_code = Net::LDAP::ResultCodeInvalidCredentials

    error = assert_raises(LdapAuthenticator::Error) { authenticate(use_admin: true) }
    assert_match 'search bind failed', error.message
    assert_nil @connection.bind_options
  end

  test 'surfaces directory search errors' do
    @connection.entries = nil
    @connection.search_code = Net::LDAP::ResultCodeUnavailable

    error = assert_raises(LdapAuthenticator::Error) { authenticate }
    assert_match 'search failed', error.message
    assert_nil @connection.bind_options
  end

  test 'rejects partial and ambiguous search results' do
    @connection.entries = [@entry, Net::LDAP::Entry.new('uid=other,dc=example,dc=test')]
    @connection.search_code = Net::LDAP::ResultCodeSizeLimitExceeded
    error = assert_raises(LdapAuthenticator::Error) { authenticate }
    assert_match 'multiple matching users', error.message

    @connection.entries = [@entry]
    error = assert_raises(LdapAuthenticator::Error) { authenticate }
    assert_match 'search failed', error.message
  end

  test 'rejects an empty DN returned by the directory' do
    @connection.entries = [Net::LDAP::Entry.new]

    error = assert_raises(LdapAuthenticator::Error) { authenticate }
    assert_match 'empty DN', error.message
    assert_nil @connection.bind_options
  end

  test 'surfaces connection timeouts without exposing credentials' do
    @connection.open_error = Timeout::Error.new('timeout')

    error = assert_raises(LdapAuthenticator::Error) { authenticate }
    assert_match 'Timeout::Error', error.message
    assert_not_includes error.message, 'user-secret'
    assert_instance_of Timeout::Error, error.cause
  end

  test 'explains how to trust the server certificate when TLS verification fails' do
    [
      'SSL_connect returned=1 errno=0 peeraddr=10.0.0.5:636 state=error: certificate verify failed (self-signed certificate)',
      'hostname "10.0.0.5" does not match the server certificate'
    ].each do |message|
      @connection.open_error = Net::LDAP::Error.new(message)

      error = assert_raises(LdapAuthenticator::Error) { authenticate }
      assert_includes error.message, 'TLS certificate verification failed'
      assert_includes error.message, message
      assert_includes error.message, 'encryption.tls_options.ca_file'
      assert_not_includes error.message, 'user-secret'
      assert_same @connection.open_error, error.cause
    end
  end

  test 'keeps the generic message for connection failures unrelated to TLS verification' do
    @connection.open_error = Net::LDAP::Error.new('Unable to connect to any given server')

    error = assert_raises(LdapAuthenticator::Error) { authenticate }
    assert_equal 'LDAP connection failed (Net::LDAP::Error)', error.message
  end

  test 'rejects missing configuration and unsupported group checks' do
    assert_raises(LdapAuthenticator::Error) { authenticate(config: @config.merge(host: '')) }
    assert_raises(LdapAuthenticator::Error) { authenticate(config: @config.merge(port: 0)) }
    assert_raises(LdapAuthenticator::Error) { authenticate(config: @config.merge(admin_password: ''), use_admin: true) }
    assert_raises(LdapAuthenticator::Error) { authenticate(config: @config.merge(check_group_membership: true)) }
  end

  private

  def capture_logs
    output = StringIO.new
    previous_logger = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(output)
    yield
    output.string
  ensure
    Rails.logger = previous_logger
  end

  def authenticate(login: 'alice', password: 'user-secret', config: @config, use_admin: false)
    LdapAuthenticator.new(config: config, use_admin: use_admin, ldap_factory: @factory).authenticate(login, password)
  end
end
