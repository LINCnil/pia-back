ENV["RAILS_ENV"] ||= "test"

require 'simplecov'
SimpleCov.start

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  include FactoryBot::Syntax::Methods

  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all

    # Set up ActiveStorage URL options for tests
    setup do
      ActiveStorage::Current.url_options = Rails.application.routes.default_url_options
    end

    # Add more helper methods to be used by all tests here...
    def doorkeeper_token
      user = FactoryBot.create(:user)
      oauth_application = Doorkeeper::Application.find_or_create_by!(name: "PIA", redirect_uri: "urn:ietf:wg:oauth:2.0:oob", scopes: %w[read write])
      Doorkeeper::AccessToken.find_or_create_by!(application: oauth_application, resource_owner_id: user.id).token
    end

    def capture_logs
      output = StringIO.new
      previous_logger = Rails.logger
      Rails.logger = ActiveSupport::Logger.new(output)
      yield
      output.string
    ensure
      Rails.logger = previous_logger
    end

    # Sets (or, with nil, unsets) environment variables for the block and restores them afterwards.
    def with_env(overrides)
      previous = overrides.keys.index_with { |name| ENV.fetch(name, nil) }
      assign_env(overrides)
      yield
    ensure
      assign_env(previous)
    end

    private

    def assign_env(values)
      values.each { |name, value| value.nil? ? ENV.delete(name) : ENV[name] = value }
    end
  end
end
