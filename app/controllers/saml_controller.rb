class SamlController < Doorkeeper::TokensController
  # skip_before_action :doorkeeper_authorize!

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(settings, true)
  end

  def sso
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(settings), allow_other_host: true)
  end

  def consume
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings:)

    if response.is_valid?
      email = response.name_id
      session[:nameid] = response.name_id
      user = User.find_by("LOWER(email) = ?", email.strip.downcase)
      if user
        user.unlock_access!
      else
        password = [*'0'..'9', *'a'..'z', *'A'..'Z', *'!'..'?'].sample(16).join
        user = User.create!(email:, password:, password_confirmation: password)
        user.is_user = true
        user.unlock_access!
        user.save
      end
      sign_in(:user, user)

      doorkeeper_app = Doorkeeper::Application.first
      access_token = Doorkeeper::AccessToken.find_or_create_for(
        application: doorkeeper_app,
        resource_owner: user.id,
        scopes: Doorkeeper::OAuth::Scopes.from_array(%w[public])
      )

      # redirect_to  frontrnd
      redirect_to "#{ENV['SSO_FRONTEND_REDIRECTION']}/#/?sso_token=#{access_token.token}", allow_other_host: true
    else
      logger.info "Response Invalid. Errors: #{response.errors}"
      @errors = response.errors
      redirect_to ENV['SSO_FRONTEND_REDIRECTION'], allow_other_host: true
    end
  end

  def logout
    logout_request = OneLogin::RubySaml::Logoutrequest.new
    session[:transaction_id] = logout_request.uuid

    logger.info "New SP SLO for User ID: '#{session[:nameid]}', Transaction ID: '#{session[:transaction_id]}'"

    settings.name_identifier_value = session[:nameid] if settings.name_identifier_value.nil?

    redirect_to(logout_request.create(settings), allow_other_host: true)
  end

  # Handle the SLO response from the IdP
  # GET /saml/slo
  def slo
    logout_response = if session.has_key? :transaction_id
                        OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings,
                                                               matches_request_id: session[:transaction_id])
                      else
                        OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
                      end
    logger.info "LogoutResponse is: #{logout_response}"

    # Validate the SAML Logout Response
    if !logout_response.validate
      logger.error 'The SAML Logout Response is invalid'
    else
      # Actually log out this session
      logger.info "SLO completed for '#{session[:nameid]}'"
      session[:nameid] = nil
      session[:transaction_id] = nil

      redirect_to ENV['SSO_FRONTEND_REDIRECTION'], allow_other_host: true
    end
  end

  private

  def settings
    settings = OneLogin::RubySaml::Settings.new
    url_base = "#{request.protocol}#{request.host_with_port}"

    # settings.soft = true
    settings.issuer = "#{url_base}/saml/metadata"
    settings.assertion_consumer_service_url = "#{url_base}/saml/acs"
    settings.assertion_consumer_logout_service_url = "#{url_base}/saml/slo"

    # IdP section
    settings.idp_entity_id                  = ENV['IDP_ENTITY_ID']
    settings.idp_sso_target_url             = ENV['IDP_SSO_TARGET_URL']
    settings.idp_slo_target_url             = ENV['IDP_SLO_TARGET_URL']
    settings.idp_cert_fingerprint           = ENV['IDP_CERT_FINGERPRINT']
    settings.idp_cert_fingerprint_algorithm = ENV['IDP_CERT_FINGERPRINT_ALGORITHM']
    settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'

    settings
  end
end
