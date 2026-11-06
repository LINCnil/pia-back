require 'test_helper'
require 'active_support/testing/constant_stubbing'

class LdapAuthenticationTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::ConstantStubbing
  include FactoryBot::Syntax::Methods

  UNSET_LDAP_SETTINGS = {
    'LDAP_ENABLED' => nil,
    'LDAP_ADMIN_BIND' => nil,
    'DEVISE_LDAP_LOGGER' => nil,
    'DEVISE_LDAP_LOGGER_ADMIN_BIND' => nil
  }.freeze
  ENABLED_LDAP = { 'LDAP_ENABLED' => 'true' }.freeze

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
    result = LdapAuthenticator::Result.new(email: 'new@example.test', login: 'alice')

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

  test 'finds the existing account by the directory login whatever the typed spelling' do
    user = create(:user, login: 'alice', email: 'alice@example.test')
    result = LdapAuthenticator::Result.new(email: 'alice@example.test', login: 'alice')

    assert_no_difference 'User.count' do
      with_ldap(result: result) { request_token('  ALICE ', 'ldap-secret') }
    end

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
  end

  test 'still finds an account created with the typed spelling by the previous integration' do
    user = create(:user, login: 'ALICE', email: 'alice@example.test')
    result = LdapAuthenticator::Result.new(email: 'alice@example.test', login: 'alice')

    assert_no_difference 'User.count' do
      with_ldap(result: result) { request_token('ALICE', 'ldap-secret') }
    end

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
    assert_equal 'ALICE', user.reload.login
  end

  test 'prefers the account with the directory login over one with the typed spelling' do
    create(:user, login: 'ALICE', email: 'old@example.test')
    user = create(:user, login: 'alice', email: 'alice@example.test')
    result = LdapAuthenticator::Result.new(email: 'alice@example.test', login: 'alice')

    with_ldap(result: result) { request_token('ALICE', 'ldap-secret') }

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
  end

  test 'creates a local user after the first successful LDAP login' do
    result = LdapAuthenticator::Result.new(email: 'alice@example.test', login: 'alice')

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

  test 'creates the local user with the directory login rather than the typed one' do
    result = LdapAuthenticator::Result.new(email: 'alice@example.test', login: 'alice')

    assert_difference 'User.count', 1 do
      with_ldap(result: result) { request_token('ALICE', 'ldap-secret') }
    end

    assert_response :success
    assert_nil User.find_by(login: 'ALICE')
    assert_equal User.find_by!(login: 'alice').id, access_token.resource_owner_id
  end

  test 'uses the login as email when LDAP does not supply one' do
    result = LdapAuthenticator::Result.new(email: nil, login: 'alice')

    with_ldap(result: result) { request_token('alice', 'ldap-secret') }

    assert_response :success
    assert_equal 'alice', User.find_by!(login: 'alice').email
  end

  test 'falls back to existing local credentials after LDAP rejects credentials' do
    user = create(:user, email: 'local@example.test')

    with_ldap(result: nil) do |attempts|
      request_token(user.email, 'Password123-')
      assert_equal [[user.email, 'Password123-']], attempts
    end

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
  end

  test 'LDAP_ENABLED=false keeps LDAP out of the login even when the deprecated variable is set' do
    user = create(:user, email: 'local@example.test')
    result = LdapAuthenticator::Result.new(email: 'alice@example.test', login: 'alice')
    settings = { 'LDAP_ENABLED' => 'false', 'DEVISE_LDAP_LOGGER' => 'true' }

    assert_no_difference 'User.count' do
      with_ldap(result: result, settings: settings) do |attempts|
        request_token(user.email, 'Password123-')
        assert_empty attempts
      end
    end

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
  end

  test 'the deprecated DEVISE_LDAP_LOGGER still enables LDAP whatever its value' do
    result = LdapAuthenticator::Result.new(email: 'alice@example.test', login: 'alice')

    with_ldap(result: result, settings: { 'DEVISE_LDAP_LOGGER' => 'false' }) do |attempts|
      request_token('alice', 'ldap-secret')
      assert_equal [['alice', 'ldap-secret']], attempts
    end

    assert_response :success
    assert_equal User.find_by!(login: 'alice').id, access_token.resource_owner_id
  end

  test 'falls back to local credentials and logs the error when LDAP_ENABLED is invalid' do
    user = create(:user, email: 'local@example.test')

    logs = capture_logs do
      with_ldap(result: nil, settings: { 'LDAP_ENABLED' => 'maybe' }) do |attempts|
        request_token(user.email, 'Password123-')
        assert_empty attempts
      end
    end

    assert_response :success
    assert_equal user.id, access_token.resource_owner_id
    assert_includes logs,
                    'LDAP authentication error, falling back to local authentication: ' \
                    'LDAP_ENABLED must be true or false'
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
    result = LdapAuthenticator::Result.new(email: 'taken@example.test', login: 'alice')

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

  def with_ldap(result: nil, error: nil, settings: ENABLED_LDAP)
    attempts = []
    authenticator = Class.new(LdapAuthenticator) do
      define_method(:initialize) { super(config: {}, use_admin: false) }
      define_method(:authenticate) do |login, password|
        attempts << [login, password]
        raise error if error

        result
      end
    end
    with_ldap_class(authenticator, settings) { yield attempts }
  end

  def with_unreachable_ldap
    port = TCPServer.open('127.0.0.1', 0) { |server| server.addr[1] }
    config = { host: '127.0.0.1', port: port, base: 'ou=people,dc=example,dc=test', attribute: 'uid', ssl: false }
    authenticator = Class.new(LdapAuthenticator) do
      define_method(:initialize) { super(config: config, use_admin: false) }
    end
    with_ldap_class(authenticator, ENABLED_LDAP) { yield }
  end

  # Subclasses keep LdapAuthenticator::Error and ::Result resolvable while the constant is stubbed.
  def with_ldap_class(authenticator, settings)
    with_env(UNSET_LDAP_SETTINGS.merge(settings)) do
      stub_const(Object, :LdapAuthenticator, authenticator) { yield }
    end
  end

  def with_ldap_disabled(&)
    with_env(UNSET_LDAP_SETTINGS, &)
  end
end
