require 'net/ldap'
require 'net/ldap/dn'
require 'openssl'
require 'timeout'

class LdapAuthenticator
  Error = Class.new(StandardError)
  # login is the user's login as spelled by the directory, never blank.
  Result = Data.define(:email, :login)

  CONNECT_TIMEOUT = 5
  # Time limit asked of the directory server for a search; REQUEST_TIMEOUT bounds the whole exchange on our side.
  SEARCH_TIME_LIMIT = 5
  REQUEST_TIMEOUT = 10
  ANONYMOUS_BIND_DENIED = [
    Net::LDAP::ResultCodeInappropriateAuthentication,
    Net::LDAP::ResultCodeInvalidCredentials,
    Net::LDAP::ResultCodeInsufficientAccessRights,
    Net::LDAP::ResultCodeUnwillingToPerform
  ].freeze
  ANONYMOUS_SEARCH_DENIED = [
    Net::LDAP::ResultCodeInappropriateAuthentication,
    Net::LDAP::ResultCodeInsufficientAccessRights
  ].freeze
  # net-ldap flattens TLS handshake errors into a plain Net::LDAP::Error, keeping only the message.
  TLS_VERIFICATION_FAILURE = /certificate verify failed|does not match the server certificate/i
  TRUE_VALUES = %w[true 1 yes on].freeze
  FALSE_VALUES = %w[false 0 no off].freeze

  class << self
    # LDAP_ENABLED wins when set. Otherwise the deprecated DEVISE_LDAP_LOGGER keeps its historical meaning:
    # any non-empty value enables LDAP, even "false".
    def enabled?
      value = ENV['LDAP_ENABLED']
      return parse_boolean('LDAP_ENABLED', value) if value.present?

      legacy_enabled?
    end

    # LDAP_ADMIN_BIND wins when set. Otherwise the deprecated DEVISE_LDAP_LOGGER_ADMIN_BIND keeps its historical
    # meaning: any defined value enables the admin bind, even an empty one or "false".
    def admin_bind?
      value = ENV['LDAP_ADMIN_BIND']
      return parse_boolean('LDAP_ADMIN_BIND', value) if value.present?

      legacy_admin_bind?
    end

    def warn_about_deprecated_settings
      warn_deprecated('DEVISE_LDAP_LOGGER', 'LDAP_ENABLED', legacy_enabled?)
      warn_deprecated('DEVISE_LDAP_LOGGER_ADMIN_BIND', 'LDAP_ADMIN_BIND', legacy_admin_bind?)
    end

    private

    def legacy_enabled?
      ENV['DEVISE_LDAP_LOGGER'].present?
    end

    def legacy_admin_bind?
      ENV.key?('DEVISE_LDAP_LOGGER_ADMIN_BIND')
    end

    def parse_boolean(name, value)
      normalized = value.strip.downcase
      return true if TRUE_VALUES.include?(normalized)
      return false if FALSE_VALUES.include?(normalized)

      raise Error, "#{name} must be true or false"
    end

    def warn_deprecated(legacy, current, legacy_value)
      return unless ENV.key?(legacy)

      Rails.logger.warn(
        if ENV[current].present?
          "#{legacy} is deprecated and ignored because #{current} is set; remove it"
        else
          "#{legacy} is deprecated and currently counts as #{current}=#{legacy_value}; set #{current} instead"
        end
      )
    end
  end

  def initialize(config: Rails.application.config_for(:ldap), use_admin: self.class.admin_bind?,
                 ldap_factory: Net::LDAP)
    @config = config.to_h.deep_symbolize_keys
    @use_admin = use_admin
    @ldap_factory = ldap_factory
  end

  def authenticate(login, password)
    return unless login.is_a?(String) && login.present? && !login.include?("\0")
    return unless password.is_a?(String) && password.present?

    validate_config!
    Timeout.timeout(REQUEST_TIMEOUT) do
      ldap = @ldap_factory.new(connection_options)
      ldap.open do |connection|
        code = connection.get_operation_result.code
        entry = if code == Net::LDAP::ResultCodeSuccess
                  find_entry(connection, login)
                elsif !@use_admin && ANONYMOUS_BIND_DENIED.include?(code)
                  nil
                else
                  raise Error, "LDAP search bind failed (result code #{code})"
                end

        dn = if entry
               entry.dn
             else
               Rails.logger.info('LDAP search did not return the user; using the legacy DN format')
               Net::LDAP::DN.new(@config[:attribute], login, @config[:base]).to_s
             end
        raise Error, 'LDAP search returned an empty DN' if dn.blank?

        if connection.bind(method: :simple, username: dn, password: password)
          Result.new(email: entry&.first(:mail), login: canonical_login(entry, login))
        else
          # Servers use many codes for a refused user bind (wrong password, locked or disabled account...).
          Rails.logger.info("LDAP user bind refused (result code #{connection.get_operation_result.code})")
          nil
        end
      end
    end
  rescue Timeout::Error, Net::LDAP::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => error
    raise Error, connection_failure_message(error), cause: error
  end

  private

  def connection_failure_message(error)
    return "LDAP connection failed (#{error.class})" unless error.message.match?(TLS_VERIFICATION_FAILURE)

    "LDAP TLS certificate verification failed (#{error.message}); " \
      'trust the server certificate authority with encryption.tls_options.ca_file'
  end

  def find_entry(connection, login)
    entries = connection.search(
      base: @config[:base],
      filter: Net::LDAP::Filter.equals(@config[:attribute], login),
      attributes: ['mail', @config[:attribute]].uniq(&:downcase),
      size: 2,
      time: SEARCH_TIME_LIMIT,
      ignore_server_caps: true
    )
    result = connection.get_operation_result
    code = result.code
    raise Error, 'LDAP search returned multiple matching users' if entries && entries.size > 1
    return entries.first if code == Net::LDAP::ResultCodeSuccess && entries
    return if anonymous_search_denied?(result)

    raise Error, "LDAP search failed (result code #{code})"
  end

  # Directories match logins case-insensitively and ignore extra spaces, so the typed login may differ from the
  # stored one. Prefer the exact stored value, then the first one equal to the typed login once normalized.
  def canonical_login(entry, typed_login)
    values = entry ? entry[@config[:attribute]].map(&:to_s) : []
    values.find { |value| value == typed_login } ||
      values.find { |value| normalize_login(value) == normalize_login(typed_login) } ||
      typed_login
  end

  def normalize_login(value)
    value.strip.gsub(/\s+/, ' ').downcase
  end

  def anonymous_search_denied?(result)
    return false if @use_admin
    return true if ANONYMOUS_SEARCH_DENIED.include?(result.code)

    # Active Directory reports this operations error when anonymous searches are disabled.
    result.code == Net::LDAP::ResultCodeOperationsError &&
      result.error_message.to_s.match?(/successful bind must be completed/i)
  end

  def validate_config!
    %i[host base attribute].each do |key|
      raise Error, "LDAP #{key} must be configured" unless @config[key].is_a?(String) && @config[key].present?
    end

    port = @config[:port]
    port = port.to_i if port.is_a?(String) && port.match?(/\A\d+\z/)
    raise Error, 'LDAP port must be between 1 and 65535' unless port.is_a?(Integer) && (1..65_535).cover?(port)

    @port = port
    if @use_admin && %i[admin_user admin_password].any? { |key| !@config[key].is_a?(String) || @config[key].blank? }
      raise Error, 'LDAP admin credentials must be configured'
    end
    if @config[:check_group_membership] || @config[:check_group_membership_without_admin]
      raise Error, 'LDAP group membership checks are not supported'
    end
  end

  def connection_options
    options = { host: @config[:host], port: @port, connect_timeout: CONNECT_TIMEOUT }
    if @use_admin
      options[:auth] = { method: :simple, username: @config[:admin_user], password: @config[:admin_password] }
    end

    encryption = encryption_options
    if encryption
      options[:encryption] = encryption
    else
      Rails.logger.warn('LDAP connection is unencrypted; credentials will be sent in clear text')
    end
    options
  end

  def encryption_options
    setting = @config[:encryption] || @config[:ssl]
    return if setting.nil? || setting == false || setting == ''

    options = case setting
              when true
                { method: :simple_tls }
              when String, Symbol
                { method: setting.to_sym }
              when Hash
                setting.deep_symbolize_keys
              else
                raise Error, 'Invalid LDAP encryption configuration'
              end
    method = options[:method]
    method = method.to_sym if method.is_a?(String)
    raise Error, 'LDAP encryption must use simple_tls or start_tls' unless %i[simple_tls start_tls].include?(method)

    { method: method, tls_options: tls_options_for(options) }
  end

  # Verification can only be disabled through the explicit verify_certificates flag, never through tls_options.
  def tls_options_for(options)
    tls_options = options.fetch(:tls_options, {})
    raise Error, 'LDAP TLS options must be a hash' unless tls_options.is_a?(Hash)

    verify = options[:verify_certificates]
    verify = true if verify.nil?
    raise Error, 'LDAP verify_certificates must be true or false' unless [true, false].include?(verify)

    if verify
      tls_options.symbolize_keys.merge(verify_mode: OpenSSL::SSL::VERIFY_PEER, verify_hostname: true)
    else
      Rails.logger.warn(
        'LDAP TLS certificate and hostname verification is disabled; the directory server identity is not checked'
      )
      tls_options.symbolize_keys.merge(verify_mode: OpenSSL::SSL::VERIFY_NONE, verify_hostname: false)
    end
  end
end
