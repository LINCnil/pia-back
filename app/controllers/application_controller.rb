class ApplicationController < ActionController::API
  before_action :doorkeeper_authorize! if ENV['ENABLE_AUTHENTICATION'].present?
end
