require 'test_helper'
require 'authorization_helper'

class OauthControllerTest < ActionDispatch::IntegrationTest
  include AuthorizationHelper
  include Devise::Test::IntegrationHelpers

  setup do
    if ENV['ENABLE_AUTHENTICATION'].present?

    end
    @pia = FactoryBot.create(:pia)
    @admin = FactoryBot.create(:user_admin, identifier: "admin")
    @doorkeeper_token = doorkeeper_token
    @auth = FactoryBot.create(:access_token)
    @auth_tokens = nil
  end

  test "should not access to pia because is not logged" do
    get pias_url
    assert_response :unauthorized
  end

  test "admin authentification and get pias" do
    @auth_tokens = auth_tokens_for_user(@admin, @auth)
    @doorkeeper_token = @auth_tokens['access_token']

    get pias_url, headers: { 'Authorization' => "Bearer #{@doorkeeper_token}" }, as: :json
    assert_response :success
  end
end
