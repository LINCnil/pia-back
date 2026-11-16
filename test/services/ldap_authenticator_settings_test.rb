require 'test_helper'

class LdapAuthenticatorSettingsTest < ActiveSupport::TestCase
  LDAP_ENV = {
    'LDAP_ENABLED' => nil,
    'LDAP_ADMIN_BIND' => nil,
    'DEVISE_LDAP_LOGGER' => nil,
    'DEVISE_LDAP_LOGGER_ADMIN_BIND' => nil
  }.freeze

  test 'LDAP is disabled and anonymous by default' do
    with_ldap_env do
      assert_not LdapAuthenticator.enabled?
      assert_not LdapAuthenticator.admin_bind?
    end
  end

  test 'LDAP_ENABLED accepts boolean spellings' do
    %w[true TRUE 1 yes On].push(' true ').each do |value|
      with_ldap_env('LDAP_ENABLED' => value) { assert LdapAuthenticator.enabled?, value.inspect }
    end
    %w[false False 0 no OFF].push(' false ').each do |value|
      with_ldap_env('LDAP_ENABLED' => value) { assert_not LdapAuthenticator.enabled?, value.inspect }
    end
  end

  test 'LDAP_ENABLED rejects values that are not booleans' do
    %w[maybe ture 2 enabled].each do |value|
      with_ldap_env('LDAP_ENABLED' => value) do
        error = assert_raises(LdapAuthenticator::Error) { LdapAuthenticator.enabled? }

        assert_equal 'LDAP_ENABLED must be true or false', error.message
      end
    end
  end

  test 'the deprecated DEVISE_LDAP_LOGGER enables LDAP for any non-empty value, even false' do
    %w[true false anything].each do |value|
      with_ldap_env('DEVISE_LDAP_LOGGER' => value) { assert LdapAuthenticator.enabled?, value }
    end
    with_ldap_env('DEVISE_LDAP_LOGGER' => '') { assert_not LdapAuthenticator.enabled? }
  end

  test 'LDAP_ENABLED takes precedence over DEVISE_LDAP_LOGGER' do
    with_ldap_env('LDAP_ENABLED' => 'false', 'DEVISE_LDAP_LOGGER' => 'true') { assert_not LdapAuthenticator.enabled? }
    with_ldap_env('LDAP_ENABLED' => 'true', 'DEVISE_LDAP_LOGGER' => '') { assert LdapAuthenticator.enabled? }
  end

  test 'a blank LDAP_ENABLED defers to DEVISE_LDAP_LOGGER' do
    with_ldap_env('LDAP_ENABLED' => '', 'DEVISE_LDAP_LOGGER' => 'true') { assert LdapAuthenticator.enabled? }
    with_ldap_env('LDAP_ENABLED' => '  ') { assert_not LdapAuthenticator.enabled? }
  end

  test 'LDAP_ADMIN_BIND accepts boolean spellings' do
    %w[true TRUE 1 yes On].push(' true ').each do |value|
      with_ldap_env('LDAP_ADMIN_BIND' => value) { assert LdapAuthenticator.admin_bind?, value.inspect }
    end
    %w[false False 0 no OFF].push(' false ').each do |value|
      with_ldap_env('LDAP_ADMIN_BIND' => value) { assert_not LdapAuthenticator.admin_bind?, value.inspect }
    end
  end

  test 'LDAP_ADMIN_BIND rejects values that are not booleans' do
    %w[maybe ture 2 enabled].each do |value|
      with_ldap_env('LDAP_ADMIN_BIND' => value) do
        error = assert_raises(LdapAuthenticator::Error) { LdapAuthenticator.admin_bind? }

        assert_equal 'LDAP_ADMIN_BIND must be true or false', error.message
      end
    end
  end

  test 'the deprecated DEVISE_LDAP_LOGGER_ADMIN_BIND enables the admin bind whenever it is defined' do
    ['true', 'false', ''].each do |value|
      with_ldap_env('DEVISE_LDAP_LOGGER_ADMIN_BIND' => value) { assert LdapAuthenticator.admin_bind?, value.inspect }
    end
  end

  test 'LDAP_ADMIN_BIND takes precedence over DEVISE_LDAP_LOGGER_ADMIN_BIND' do
    with_ldap_env('LDAP_ADMIN_BIND' => 'false', 'DEVISE_LDAP_LOGGER_ADMIN_BIND' => 'true') do
      assert_not LdapAuthenticator.admin_bind?
    end
    with_ldap_env('LDAP_ADMIN_BIND' => 'true', 'DEVISE_LDAP_LOGGER_ADMIN_BIND' => '') do
      assert LdapAuthenticator.admin_bind?
    end
  end

  test 'a blank LDAP_ADMIN_BIND defers to DEVISE_LDAP_LOGGER_ADMIN_BIND' do
    with_ldap_env('LDAP_ADMIN_BIND' => '', 'DEVISE_LDAP_LOGGER_ADMIN_BIND' => '') do
      assert LdapAuthenticator.admin_bind?
    end
    with_ldap_env('LDAP_ADMIN_BIND' => ' ') { assert_not LdapAuthenticator.admin_bind? }
  end

  test 'does not warn when only the new variables are used' do
    output = capture_logs do
      with_ldap_env('LDAP_ENABLED' => 'true', 'LDAP_ADMIN_BIND' => 'false') do
        LdapAuthenticator.warn_about_deprecated_settings
      end
    end

    assert_empty output
  end

  test 'warns that deprecated variables count as the value they currently evaluate to' do
    output = capture_logs do
      with_ldap_env('DEVISE_LDAP_LOGGER' => 'false', 'DEVISE_LDAP_LOGGER_ADMIN_BIND' => '') do
        LdapAuthenticator.warn_about_deprecated_settings
      end
    end

    assert_includes output,
                    'DEVISE_LDAP_LOGGER is deprecated and currently counts as LDAP_ENABLED=true; ' \
                    'set LDAP_ENABLED instead'
    assert_includes output,
                    'DEVISE_LDAP_LOGGER_ADMIN_BIND is deprecated and currently counts as LDAP_ADMIN_BIND=true; ' \
                    'set LDAP_ADMIN_BIND instead'
  end

  test 'warns that an empty DEVISE_LDAP_LOGGER counts as disabled' do
    output = capture_logs do
      with_ldap_env('DEVISE_LDAP_LOGGER' => '') { LdapAuthenticator.warn_about_deprecated_settings }
    end

    assert_includes output, 'DEVISE_LDAP_LOGGER is deprecated and currently counts as LDAP_ENABLED=false'
    assert_not_includes output, 'LDAP_ADMIN_BIND'
  end

  test 'warns that deprecated variables are ignored once their replacement is set' do
    output = capture_logs do
      with_ldap_env('DEVISE_LDAP_LOGGER' => 'true', 'LDAP_ENABLED' => 'false',
                    'DEVISE_LDAP_LOGGER_ADMIN_BIND' => 'true', 'LDAP_ADMIN_BIND' => 'true') do
        LdapAuthenticator.warn_about_deprecated_settings
      end
    end

    assert_includes output, 'DEVISE_LDAP_LOGGER is deprecated and ignored because LDAP_ENABLED is set; remove it'
    assert_includes output,
                    'DEVISE_LDAP_LOGGER_ADMIN_BIND is deprecated and ignored because LDAP_ADMIN_BIND is set; remove it'
  end

  private

  def with_ldap_env(overrides = {}, &)
    with_env(LDAP_ENV.merge(overrides), &)
  end
end
