require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include AuthentificationHelper
  setup do
    # let(:token) { FactoryBot.create(:access_token) }
    @Auth = AppWithAuth.new
    @user = create(:user)
    @Auth.sign_in_as_user @user, oauth_token_url
  end

  test "test create route" do
    post users_url, params: {
      firstname: "test",
      lastname: "test",
      email: "test@email.test",
      access_type: ['user']
    }, headers: {
      "Authorization": "Bearer #{@Auth.auth_token}"
    }

    assert_response :success
  end
end
