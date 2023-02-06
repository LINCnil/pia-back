require 'test_helper'
# require "authentification_helper"
require 'authorization_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include AuthorizationHelper
  setup do
    @auth = create(:access_token)
    @admin = create(:user_admin)
    @auth_tokens = auth_tokens_for_user(@admin, @auth)
  end

  test "test create route" do
    post users_url, params: {
      firstname: "new",
      lastname: "user",
      email: "user+create@test.com",
      access_type: ['user']
    }, headers: {
      "Authorization": "Bearer #{@auth_tokens['access_token']}"
    }

    assert_response :success
  end
end
