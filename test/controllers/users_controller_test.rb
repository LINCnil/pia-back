require 'test_helper'
require 'authorization_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include AuthorizationHelper
  setup do
    @auth = create(:access_token)
    @admin = create(:user_admin, identifier: "admin")
    @auth_tokens = auth_tokens_for_user(@admin, @auth)
  end

  test "test create route + new user is locked" do
    post users_url, params: {
      user: {
        firstname: "new",
        lastname: "user",
        email: "user+create@test.com",
        access_type: ['user']
      }
    }, headers: {
      "Authorization": "Bearer #{@auth_tokens['access_token']}"
    }

    assert_response :success

    new_user = JSON.parse(response.body)
    assert_equal new_user['access_locked'], true
  end

  test "test update route" do
    @user_to_update = create(:user, identifier: "functional")
    patch user_url(@user_to_update), params: {
      user: {
        firstname: "updated",
        email: "user+update@test.com",
        access_type: ['user', 'functional']
      }
    }, headers: {
      "Authorization": "Bearer #{@auth_tokens['access_token']}"
    }

    assert_response :success
  end

  test "test delete route" do
    @user_to_delete = create(:user, identifier: "functional")
    delete user_url(@user_to_delete), headers: {
      "Authorization": "Bearer #{@auth_tokens['access_token']}"
    }

    assert_response :no_content
  end
end
