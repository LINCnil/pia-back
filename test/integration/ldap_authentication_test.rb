require 'test_helper'
require 'active_support/testing/constant_stubbing'

class LdapAuthenticationTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::ConstantStubbing
  include FactoryBot::Syntax::Methods

  setup do
    @application = Doorkeeper::Application.create!(
      name: 'LDAP test client',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      scopes: 'read write'
    )
  end

  test 'authenticates local users when LDAP is disabled' do
    user = create(:user, email: 'local@example.test')

    with_ldap_disabled { request_token(user.email, 'Password123-') }

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
  end

  test 'authenticates an existing LDAP user without creating another account' do
    user = create(:user, login: 'alice', email: 'alice@example.test')
    result = LdapAuthenticator::Result.new(email: 'new@example.test')

    assert_no_difference 'User.count' do
      with_ldap(result: result) do |attempts|
        request_token('alice', 'ldap-secret')
        assert_equal [['alice', 'ldap-secret']], attempts
      end
    end

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
    assert_equal 'alice@example.test', user.reload.email
  end

  test 'creates a local user after the first successful LDAP login' do
    result = LdapAuthenticator::Result.new(email: 'alice@example.test')

    assert_difference 'User.count', 1 do
      with_ldap(result: result) { request_token('alice', 'ldap-secret') }
    end

    assert_response :success
    user = User.find_by!(login: 'alice')
    assert_equal 'alice@example.test', user.email
    assert user.is_user
    assert user.uuid.present?
    assert_equal user.id, access_token.resource_owner_id
    assert_not user.valid_password?('ldap-secret')
  end

  test 'uses the login as email when LDAP does not supply one' do
    result = LdapAuthenticator::Result.new(email: nil)

    with_ldap(result: result) { request_token('alice', 'ldap-secret') }

    assert_response :success
    assert_equal 'alice', User.find_by!(login: 'alice').email
  end

  test 'falls back to existing local credentials after LDAP rejects credentials' do
    user = create(:user, email: 'local@example.test')

    with_ldap(result: nil, enabled_value: 'false') { request_token(user.email, 'Password123-') }

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
  end

  test 'rejects credentials that fail both LDAP and local authentication' do
    user = create(:user, email: 'local@example.test')

    assert_no_difference 'Doorkeeper::AccessToken.count' do
      with_ldap(result: nil) { request_token(user.email, 'wrong-password') }
    end

    assert_response :bad_request
    assert_equal 'invalid_grant', response.parsed_body['error']
  end

  test 'falls back to local credentials and logs the error when LDAP is unavailable' do
    user = create(:user, email: 'local@example.test')
    error = LdapAuthenticator::Error.new('LDAP connection failed (Net::LDAP::Error)')

    logs = capture_logs { with_ldap(error: error) { request_token(user.email, 'Password123-') } }

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
    assert_includes logs,
                    'LDAP authentication error, falling back to local authentication: ' \
                    'LDAP connection failed (Net::LDAP::Error)'
  end

  test 'rejects wrong local credentials when LDAP is unavailable' do
    user = create(:user, email: 'local@example.test')
    error = LdapAuthenticator::Error.new('LDAP unavailable')

    assert_no_difference 'Doorkeeper::AccessToken.count' do
      with_ldap(error: error) { request_token(user.email, 'wrong-password') }
    end

    assert_response :bad_request
    assert_equal 'invalid_grant', response.parsed_body['error']
  end

  test 'does not accept the LDAP password of a provisioned user when LDAP is unavailable' do
    User.create_with_ldap('alice', 'alice@example.test')
    error = LdapAuthenticator::Error.new('LDAP unavailable')

    assert_no_difference 'Doorkeeper::AccessToken.count' do
      with_ldap(error: error) { request_token('alice@example.test', 'ldap-secret') }
    end

    assert_response :bad_request
    assert_equal 'invalid_grant', response.parsed_body['error']
  end

  test 'falls back to local credentials when the directory refuses the connection' do
    user = create(:user, email: 'local@example.test')

    logs = capture_logs { with_unreachable_ldap { request_token(user.email, 'Password123-') } }

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
    assert_match(/falling back to local authentication: LDAP connection failed \(/, logs)
  end

  test 'does not issue a token when the LDAP user cannot be saved' do
    create(:user, email: 'taken@example.test')
    result = LdapAuthenticator::Result.new(email: 'taken@example.test')

    assert_no_difference 'Doorkeeper::AccessToken.count' do
      with_ldap(result: result) { request_token('alice', 'ldap-secret') }
    end
    assert_response :unprocessable_entity
    assert_nil User.find_by(login: 'alice')
  end

  private

  def request_token(login, password)
    post '/oauth/token', params: {
      grant_type: 'password',
      email: login,
      password: password,
      client_id: @application.uid,
      client_secret: @application.secret
    }
  end

  def access_token
    Doorkeeper::AccessToken.find_by!(token: response.parsed_body.fetch('access_token'))
  end

  def with_ldap(result: nil, error: nil, enabled_value: 'true')
    attempts = []
    authenticator = Class.new(LdapAuthenticator) do
      define_method(:initialize) { super(config: {}, use_admin: false) }
      define_method(:authenticate) do |login, password|
        attempts << [login, password]
        raise error if error

        result
      end
    end
    with_ldap_class(authenticator, enabled_value) { yield attempts }
  end

  def with_unreachable_ldap
    port = TCPServer.open('127.0.0.1', 0) { |server| server.addr[1] }
    config = { host: '127.0.0.1', port: port, base: 'ou=people,dc=example,dc=test', attribute: 'uid', ssl: false }
    authenticator = Class.new(LdapAuthenticator) do
      define_method(:initialize) { super(config: config, use_admin: false) }
    end
    with_ldap_class(authenticator, 'true') { yield }
  end

  # Subclasses keep LdapAuthenticator::Error and ::Result resolvable while the constant is stubbed.
  def with_ldap_class(authenticator, enabled_value)
    previous_value = ENV['DEVISE_LDAP_LOGGER']
    ENV['DEVISE_LDAP_LOGGER'] = enabled_value
    stub_const(Object, :LdapAuthenticator, authenticator) { yield }
  ensure
    previous_value.nil? ? ENV.delete('DEVISE_LDAP_LOGGER') : ENV['DEVISE_LDAP_LOGGER'] = previous_value
  end

  def with_ldap_disabled
    previous_value = ENV.delete('DEVISE_LDAP_LOGGER')
    yield
  ensure
    previous_value.nil? ? ENV.delete('DEVISE_LDAP_LOGGER') : ENV['DEVISE_LDAP_LOGGER'] = previous_value
  end
end
