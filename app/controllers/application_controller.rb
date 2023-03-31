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
    client_app = Doorkeeper::Application.find_by(uid: params["client_id"], secret: params["client_secret"])
    render json: { valid: client_app.present?, auth: ENV['ENABLE_AUTHENTICATION'].present? }
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
