require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PiaBack
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    config.autoload_paths << "#{Rails.root}/lib"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # set the default locale to French
    config.i18n.default_locale = :en
    # if a locale isn't found fall back to this default locale
    config.i18n.fallbacks = true
    # set the possible locales to English and Brazilian-Portuguese
    config.i18n.available_locales = %i[bg cs da de el en es et
                                       fi fr hr hu it lt lv nl
                                       no pl pt ro sl sv]

    tags_allowed = ENV['SANITIZED_ALLOWED_TAGS'] ? ENV['SANITIZED_ALLOWED_TAGS'].split(' ') : []
    config.action_view.sanitized_allowed_tags = tags_allowed
    attributes_allowed = ENV['SANITIZED_ALLOWED_ATTRIBUTES'] ? ENV['SANITIZED_ALLOWED_ATTRIBUTES'].split(' ') : []
    config.action_view.sanitized_allowed_attributes = attributes_allowed
  end
end
