# Be sure to restart your server when you modify this file.

# Set default URL options for Rails routes
# This ensures that URL helpers like url_for generate complete URLs with the host

Rails.application.routes.default_url_options = {
  # In production, use the actual host
  host: Rails.env.local? ? 'localhost' : ENV['DEFAULT_HOST'],
  # Use the correct port in development
  port: Rails.env.local? ? 3000 : nil,
  # Use HTTPS in production
  protocol: Rails.application.config.force_ssl ? 'https' : 'http'
}
