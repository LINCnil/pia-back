class ApplicationController < ActionController::API
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: :internal_server_error
  end

  include Pundit if ENV['ENABLE_AUTHENTICATION'].present?
  if ENV['ENABLE_AUTHENTICATION'].present?
    before_action :doorkeeper_authorize!,
                  except: %i[info check_uuid password_forgotten change_password]
  end

  def info
    render json: { valid: true, auth: ENV['ENABLE_AUTHENTICATION'].present? }
  end

  protected

  # Find the user that owns the access token
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    current_resource_owner
  end
end
