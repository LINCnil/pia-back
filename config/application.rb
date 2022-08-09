require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PiaBack
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0
    config.autoload_paths << "#{Rails.root}/lib"
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
