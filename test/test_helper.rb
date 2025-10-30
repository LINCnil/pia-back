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
  end
end
