# frozen_string_literal: true

require 'net/ldap'

class LdapAdapter
  class << self
    # Validates user credentials against LDAP server
    # @param login [String] the user's login identifier
    # @param password [String] the user's password
    # @return [Boolean] true if credentials are valid
    def valid_credentials?(login, password)
      return false if login.blank? || password.blank?

      ldap = create_ldap_connection
      return false unless ldap

      # Bind with admin credentials first (if configured)
      unless bind_as_admin(ldap)
        Rails.logger.error "LDAP: Failed to bind as admin"
        return false
      end

      # Search for user
      user_dn = find_user_dn(ldap, login)
      return false unless user_dn

      # Now attempt to bind as the user to validate their password
      ldap.auth(user_dn, password)
      result = ldap.bind

      if result
        Rails.logger.info "LDAP: Successfully authenticated user: #{login}"
      else
        Rails.logger.warn "LDAP: Failed to authenticate user: #{login} - #{ldap.get_operation_result.message}"
      end

      result
    rescue StandardError => e
      Rails.logger.error "LDAP: Error validating credentials for #{login}: #{e.message}"
      false
    end

    # Retrieves a specific LDAP parameter for a user
    # @param login [String] the user's login identifier
    # @param param [String] the LDAP attribute to retrieve (e.g., 'mail')
    # @return [Array, nil] array of values for the attribute, or nil if not found
    def get_ldap_param(login, param)
      return nil if login.blank? || param.blank?

      ldap = create_ldap_connection
      return nil unless ldap

      # Bind with admin credentials
      unless bind_as_admin(ldap)
        Rails.logger.error "LDAP: Failed to bind as admin"
        return nil
      end

      # Search for user and retrieve the specified parameter
      filter = Net::LDAP::Filter.eq(config[:attribute], login)
      result = ldap.search(
        base: config[:base],
        filter: filter,
        attributes: [param]
      )

      if result && result.first
        value = result.first[param]
        Rails.logger.info "LDAP: Retrieved #{param} for user #{login}"
        value
      else
        Rails.logger.warn "LDAP: Could not find #{param} for user #{login}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "LDAP: Error retrieving #{param} for #{login}: #{e.message}"
      nil
    end

    # Loads LDAP configuration from ldap.yml
    # @return [Hash] LDAP configuration hash
    def config
      @config ||= begin
        config_file = Rails.root.join('config', 'ldap.yml')
        if File.exist?(config_file)
          # Process ERB template before parsing YAML
          erb_content = ERB.new(File.read(config_file)).result
          yaml_config = YAML.safe_load(erb_content, aliases: true)
          env_config = yaml_config[Rails.env] || {}

          # Convert string keys to symbols
          env_config.transform_keys(&:to_sym)
        else
          Rails.logger.error "LDAP: Configuration file not found at #{config_file}"
          {}
        end
      end
    end

    # Resets the cached configuration (useful for testing)
    def reset_config!
      @config = nil
    end

    private

    # Creates and returns an LDAP connection
    # @return [Net::LDAP, nil] LDAP connection object or nil if config is invalid
    def create_ldap_connection
      return nil unless config[:host]

      ldap_options = {
        host: config[:host],
        port: config[:port] || 389,
        base: config[:base]
      }

      # Configure encryption
      if config[:ssl].present?
        case config[:ssl].to_s.downcase
        when 'simple_tls', 'ssl', 'tls'
          ldap_options[:encryption] = { method: :simple_tls }
        when 'start_tls'
          ldap_options[:encryption] = { method: :start_tls }
        end
      end

      Net::LDAP.new(ldap_options)
    rescue StandardError => e
      Rails.logger.error "LDAP: Error creating connection: #{e.message}"
      nil
    end

    # Binds to LDAP server with admin credentials
    # @param ldap [Net::LDAP] the LDAP connection
    # @return [Boolean] true if bind was successful
    def bind_as_admin(ldap)
      if config[:admin_user].present? && config[:admin_password].present?
        ldap.auth(config[:admin_user], config[:admin_password])
        result = ldap.bind
        unless result
          Rails.logger.error "LDAP: Admin bind failed - #{ldap.get_operation_result.message}"
        end
        result
      else
        # If no admin credentials, attempt anonymous bind
        true
      end
    end

    # Finds the distinguished name (DN) for a user
    # @param ldap [Net::LDAP] the LDAP connection
    # @param login [String] the user's login identifier
    # @return [String, nil] the user's DN or nil if not found
    def find_user_dn(ldap, login)
      filter = Net::LDAP::Filter.eq(config[:attribute], login)
      result = ldap.search(
        base: config[:base],
        filter: filter,
        attributes: ['dn']
      )

      if result && result.first
        dn = result.first.dn
        Rails.logger.info "LDAP: Found DN for user #{login}: #{dn}"
        dn
      else
        Rails.logger.warn "LDAP: Could not find DN for user #{login}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "LDAP: Error finding DN for #{login}: #{e.message}"
      nil
    end
  end
end
