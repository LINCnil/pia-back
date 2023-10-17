require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PiaBack
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # set the default locale to French
    config.i18n.default_locale = ENV.fetch('DEFAULT_LOCALE', :en)
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

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    config.secret_key_base = Rails.application.credentials.secret_key_base
    config.session_store :cookie_store, expire_after: 30.minutes
  end
end
