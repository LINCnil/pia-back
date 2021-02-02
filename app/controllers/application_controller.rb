class ApplicationController < ActionController::API
  before_action :doorkeeper_authorize!, except: :info if ENV['ENABLE_AUTHENTICATION'].present?

  def info
    render json: { valid: true, auth: ENV['ENABLE_AUTHENTICATION'].present? }
  end
end
