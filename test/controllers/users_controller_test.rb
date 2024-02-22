require 'test_helper'
require 'authorization_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include AuthorizationHelper
  setup do
    @auth = FactoryBot.create(:access_token)
    @admin = FactoryBot.create(:user_admin, identifier: "admin")
    @auth_tokens = auth_tokens_for_user(@admin, @auth)
  end

  test "test create route + new user is locked" do
    if ENV['ENABLE_AUTHENTICATION'].present?
      new_user = create_user_by_controller

      assert_response :success
      assert_equal new_user['access_locked'], true
    end
  end

  test "test update route" do
    if ENV['ENABLE_AUTHENTICATION'].present?
      user_to_update = FactoryBot.create(:user, identifier: "functional")
      patch user_url(user_to_update), params: {
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
  end

  test "test delete route" do
    if ENV['ENABLE_AUTHENTICATION'].present?
      user_to_delete = FactoryBot.create(:user, identifier: "functional")
      delete user_url(user_to_delete), headers: {
        "Authorization": "Bearer #{@auth_tokens['access_token']}"
      }

      assert_response :no_content
    end
  end

  # TODO
  test "test delete the only one admin" do
    if ENV['ENABLE_AUTHENTICATION'].present?
      user_to_delete = FactoryBot.create(:user, identifier: "technical")
      delete user_url(user_to_delete), headers: {
        "Authorization": "Bearer #{@auth_tokens['access_token']}"
      }

      # should not return a error
    end
  end

  test "test process to unlock user and set password" do
    # create a user locked by default
    new_user = FactoryBot.create(:user)
    new_user.lock_access!

    # check by uuid
    get "/users/unlock_access/" +  new_user.uuid
    assert_response :success

    # change password
    put "/users/change-password", params: {
      id: new_user.id,
      password: "newPassword12-",
      password_confirmation: "newPassword12-",
      uuid: new_user.uuid
    }
    assert_response :success

    # now he must be unlocked
    new_user.reload
    assert_equal new_user.access_locked?, false
  end

  private
  def create_user_by_controller
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

    JSON.parse(response.body)
  end
end
