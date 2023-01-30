require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "user is locked by default" do
    expect(@user.is_locked).to eq(true)
  end
end
