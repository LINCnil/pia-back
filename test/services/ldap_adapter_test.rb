# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class LdapAdapterTest < ActiveSupport::TestCase
  setup do
    # Reset config before each test
    LdapAdapter.reset_config!
  end

  teardown do
    LdapAdapter.reset_config!
  end

  # Tests for valid_credentials?

  test "valid_credentials? returns false when login is blank" do
    result = LdapAdapter.valid_credentials?('', 'password123')
    assert_not result, "Expected valid_credentials? to return false for blank login"
  end

  test "valid_credentials? returns false when password is blank" do
    result = LdapAdapter.valid_credentials?('testuser', '')
    assert_not result, "Expected valid_credentials? to return false for blank password"
  end

  test "valid_credentials? returns false when both login and password are blank" do
    result = LdapAdapter.valid_credentials?('', '')
    assert_not result, "Expected valid_credentials? to return false for blank credentials"
  end

  test "valid_credentials? returns false when LDAP host is not configured" do
    LdapAdapter.stub(:config, { host: nil }) do
      result = LdapAdapter.valid_credentials?('testuser', 'password123')
      assert_not result, "Expected valid_credentials? to return false when host is not configured"
    end
  end

  test "valid_credentials? returns true when credentials are valid" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: 'cn=admin,dc=test,dc=com',
      admin_password: 'admin_password'
    }

    ldap_mock = Minitest::Mock.new
    search_result = [OpenStruct.new(dn: 'cn=testuser,ou=people,dc=test,dc=com')]

    # Expect admin bind
    ldap_mock.expect :auth, nil, ['cn=admin,dc=test,dc=com', 'admin_password']
    ldap_mock.expect :bind, true

    # Expect user search
    ldap_mock.expect :search, search_result do |args|
      args.is_a?(Hash)
    end

    # Expect user authentication
    ldap_mock.expect :auth, nil, ['cn=testuser,ou=people,dc=test,dc=com', 'password123']
    ldap_mock.expect :bind, true

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.valid_credentials?('testuser', 'password123')
        assert result, "Expected valid_credentials? to return true"
      end
    end

    ldap_mock.verify
  end

  test "valid_credentials? returns false when admin bind fails" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: 'cn=admin,dc=test,dc=com',
      admin_password: 'admin_password'
    }

    ldap_mock = Minitest::Mock.new
    operation_result = OpenStruct.new(message: 'Invalid credentials')

    # Expect admin bind to fail
    ldap_mock.expect :auth, nil, ['cn=admin,dc=test,dc=com', 'admin_password']
    ldap_mock.expect :bind, false
    ldap_mock.expect :get_operation_result, operation_result

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.valid_credentials?('testuser', 'password123')
        assert_not result, "Expected valid_credentials? to return false when admin bind fails"
      end
    end

    ldap_mock.verify
  end

  test "valid_credentials? returns false when user DN is not found" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: 'cn=admin,dc=test,dc=com',
      admin_password: 'admin_password'
    }

    ldap_mock = Minitest::Mock.new

    # Expect admin bind to succeed
    ldap_mock.expect :auth, nil, ['cn=admin,dc=test,dc=com', 'admin_password']
    ldap_mock.expect :bind, true

    # Expect user search to return no results
    ldap_mock.expect :search, nil do |args|
      args.is_a?(Hash)
    end

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.valid_credentials?('nonexistent', 'password123')
        assert_not result, "Expected valid_credentials? to return false when user is not found"
      end
    end

    ldap_mock.verify
  end

  test "valid_credentials? returns false when user authentication fails" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: 'cn=admin,dc=test,dc=com',
      admin_password: 'admin_password'
    }

    ldap_mock = Minitest::Mock.new
    search_result = [OpenStruct.new(dn: 'cn=testuser,ou=people,dc=test,dc=com')]
    operation_result = OpenStruct.new(message: 'Invalid credentials')

    # Expect admin bind
    ldap_mock.expect :auth, nil, ['cn=admin,dc=test,dc=com', 'admin_password']
    ldap_mock.expect :bind, true

    # Expect user search
    ldap_mock.expect :search, search_result do |args|
      args.is_a?(Hash)
    end

    # Expect user authentication to fail
    ldap_mock.expect :auth, nil, ['cn=testuser,ou=people,dc=test,dc=com', 'wrongpassword']
    ldap_mock.expect :bind, false
    ldap_mock.expect :get_operation_result, operation_result

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.valid_credentials?('testuser', 'wrongpassword')
        assert_not result, "Expected valid_credentials? to return false with wrong password"
      end
    end

    ldap_mock.verify
  end

  test "valid_credentials? works with anonymous bind when admin credentials not configured" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: nil,
      admin_password: nil
    }

    ldap_mock = Minitest::Mock.new
    search_result = [OpenStruct.new(dn: 'cn=testuser,ou=people,dc=test,dc=com')]

    # No admin bind expected, just user search
    ldap_mock.expect :search, search_result do |args|
      args.is_a?(Hash)
    end

    # Expect user authentication
    ldap_mock.expect :auth, nil, ['cn=testuser,ou=people,dc=test,dc=com', 'password123']
    ldap_mock.expect :bind, true

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.valid_credentials?('testuser', 'password123')
        assert result, "Expected valid_credentials? to work with anonymous bind"
      end
    end

    ldap_mock.verify
  end

  # Tests for get_ldap_param

  test "get_ldap_param returns nil when login is blank" do
    result = LdapAdapter.get_ldap_param('', 'mail')
    assert_nil result, "Expected get_ldap_param to return nil for blank login"
  end

  test "get_ldap_param returns nil when param is blank" do
    result = LdapAdapter.get_ldap_param('testuser', '')
    assert_nil result, "Expected get_ldap_param to return nil for blank param"
  end

  test "get_ldap_param returns nil when LDAP host is not configured" do
    LdapAdapter.stub(:config, { host: nil }) do
      result = LdapAdapter.get_ldap_param('testuser', 'mail')
      assert_nil result, "Expected get_ldap_param to return nil when host is not configured"
    end
  end

  test "get_ldap_param returns attribute value when found" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: 'cn=admin,dc=test,dc=com',
      admin_password: 'admin_password'
    }

    ldap_mock = Minitest::Mock.new
    search_result = [OpenStruct.new(mail: ['user@test.com'])]

    # Expect admin bind
    ldap_mock.expect :auth, nil, ['cn=admin,dc=test,dc=com', 'admin_password']
    ldap_mock.expect :bind, true

    # Expect search for parameter
    ldap_mock.expect :search, search_result do |args|
      args.is_a?(Hash)
    end

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.get_ldap_param('testuser', 'mail')
        assert_equal ['user@test.com'], result, "Expected to retrieve mail attribute"
      end
    end

    ldap_mock.verify
  end

  test "get_ldap_param returns nil when admin bind fails" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: 'cn=admin,dc=test,dc=com',
      admin_password: 'admin_password'
    }

    ldap_mock = Minitest::Mock.new
    operation_result = OpenStruct.new(message: 'Invalid credentials')

    # Expect admin bind to fail
    ldap_mock.expect :auth, nil, ['cn=admin,dc=test,dc=com', 'admin_password']
    ldap_mock.expect :bind, false
    ldap_mock.expect :get_operation_result, operation_result

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.get_ldap_param('testuser', 'mail')
        assert_nil result, "Expected get_ldap_param to return nil when admin bind fails"
      end
    end

    ldap_mock.verify
  end

  test "get_ldap_param returns nil when user is not found" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: 'cn=admin,dc=test,dc=com',
      admin_password: 'admin_password'
    }

    ldap_mock = Minitest::Mock.new

    # Expect admin bind
    ldap_mock.expect :auth, nil, ['cn=admin,dc=test,dc=com', 'admin_password']
    ldap_mock.expect :bind, true

    # Expect search to return no results
    ldap_mock.expect :search, nil do |args|
      args.is_a?(Hash)
    end

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.get_ldap_param('nonexistent', 'mail')
        assert_nil result, "Expected get_ldap_param to return nil when user not found"
      end
    end

    ldap_mock.verify
  end

  test "get_ldap_param returns nil when user exists but attribute is not present" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      admin_user: 'cn=admin,dc=test,dc=com',
      admin_password: 'admin_password'
    }

    ldap_mock = Minitest::Mock.new
    search_result = [OpenStruct.new(cn: ['testuser'])] # Has cn but not mail

    # Expect admin bind
    ldap_mock.expect :auth, nil, ['cn=admin,dc=test,dc=com', 'admin_password']
    ldap_mock.expect :bind, true

    # Expect search
    ldap_mock.expect :search, search_result do |args|
      args.is_a?(Hash)
    end

    Net::LDAP.stub :new, ldap_mock do
      LdapAdapter.stub :config, mock_config do
        result = LdapAdapter.get_ldap_param('testuser', 'mail')
        assert_nil result, "Expected get_ldap_param to return nil when attribute not present"
      end
    end

    ldap_mock.verify
  end

  # Tests for config method

  test "config loads and parses LDAP configuration from ldap.yml" do
    config = LdapAdapter.config

    assert config.is_a?(Hash), "Expected config to return a Hash"
    assert config.key?(:host), "Expected config to have :host key"
  end

  test "config returns symbolized keys" do
    config = LdapAdapter.config

    # All keys should be symbols
    config.each_key do |key|
      assert key.is_a?(Symbol), "Expected all config keys to be symbols, got #{key.class} for #{key}"
    end
  end

  test "config caches the result" do
    config1 = LdapAdapter.config
    config2 = LdapAdapter.config

    assert_same config1, config2, "Expected config to cache the result"
  end

  test "reset_config! clears the cached configuration" do
    config1 = LdapAdapter.config
    LdapAdapter.reset_config!
    config2 = LdapAdapter.config

    assert_not_same config1, config2, "Expected reset_config! to clear the cache"
  end

  # Tests for SSL configuration

  test "creates LDAP connection with simple_tls encryption" do
    mock_config = {
      host: 'ldap.test.com',
      port: 636,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      ssl: 'simple_tls'
    }

    connection_created = false
    Net::LDAP.stub :new, ->(options) {
      connection_created = true
      assert_equal 'ldap.test.com', options[:host]
      assert_equal 636, options[:port]
      assert_equal :simple_tls, options.dig(:encryption, :method), "Expected SSL method to be :simple_tls"
      Minitest::Mock.new
    } do
      LdapAdapter.stub :config, mock_config do
        # Use get_ldap_param which will create a connection
        LdapAdapter.get_ldap_param('testuser', 'mail')
      end
    end

    assert connection_created, "Expected LDAP connection to be created"
  end

  test "creates LDAP connection with start_tls encryption" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      ssl: 'start_tls'
    }

    connection_created = false
    Net::LDAP.stub :new, ->(options) {
      connection_created = true
      assert_equal :start_tls, options.dig(:encryption, :method), "Expected SSL method to be :start_tls"
      Minitest::Mock.new
    } do
      LdapAdapter.stub :config, mock_config do
        LdapAdapter.get_ldap_param('testuser', 'mail')
      end
    end

    assert connection_created, "Expected LDAP connection to be created"
  end

  test "creates LDAP connection without encryption when ssl is false" do
    mock_config = {
      host: 'ldap.test.com',
      port: 389,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn',
      ssl: false
    }

    connection_created = false
    Net::LDAP.stub :new, ->(options) {
      connection_created = true
      assert_nil options[:encryption], "Expected no encryption when ssl is false"
      Minitest::Mock.new
    } do
      LdapAdapter.stub :config, mock_config do
        LdapAdapter.get_ldap_param('testuser', 'mail')
      end
    end

    assert connection_created, "Expected LDAP connection to be created"
  end

  test "uses default port 389 when port is not configured" do
    mock_config = {
      host: 'ldap.test.com',
      port: nil,
      base: 'ou=people,dc=test,dc=com',
      attribute: 'cn'
    }

    connection_created = false
    Net::LDAP.stub :new, ->(options) {
      connection_created = true
      assert_equal 389, options[:port], "Expected default port 389"
      Minitest::Mock.new
    } do
      LdapAdapter.stub :config, mock_config do
        LdapAdapter.get_ldap_param('testuser', 'mail')
      end
    end

    assert connection_created, "Expected LDAP connection to be created"
  end
end
