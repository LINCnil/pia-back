class ApplicationController < ActionController::API
  include Pundit if ENV['ENABLE_AUTHENTICATION'].present?
  before_action :doorkeeper_authorize!, except: :info if ENV['ENABLE_AUTHENTICATION'].present?

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
