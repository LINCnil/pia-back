require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  setup do
    @user = create(:user, email: 'testuser@example.com', uuid: SecureRandom.uuid)
    @admin_user = create(:user, is_technical_admin: true, is_functional_admin: true)
    @token = doorkeeper_token
  end

  # INDEX tests
  test 'should get index with authentication' do
    get users_url, headers: { 'Authorization' => "Bearer #{@token}" }, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
  end

  # CREATE tests
  test 'should create user with valid params' do
    ActionMailer::Base.deliveries.clear
    user_count_before = User.count

    post users_url,
         params: { user: { firstname: 'Jane', lastname: 'Smith', email: 'jane.smith@example.com' } },
         headers: { 'Authorization' => "Bearer #{@token}" },
         as: :json

    assert_response :success
    assert_equal user_count_before + 1, User.count, "Should create exactly one new user"

    json_response = JSON.parse(response.body)
    assert_equal 'Jane', json_response['firstname']
    assert_equal 'Smith', json_response['lastname']
    assert_equal 'jane.smith@example.com', json_response['email']

    # Check user is locked by default
    new_user = User.find_by(email: 'jane.smith@example.com')
    assert new_user.access_locked?

    # Check email was sent
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'should create user with access_type' do
    user_count_before = User.count

    post users_url,
         params: {
           user: {
             firstname: 'Tech',
             lastname: 'Admin',
             email: 'tech@example.com',
             access_type: ['technical', 'user']
           }
         },
         headers: { 'Authorization' => "Bearer #{@token}" },
         as: :json

    assert_response :success
    assert_equal user_count_before + 1, User.count, "Should create exactly one new user"

    new_user = User.find_by(email: 'tech@example.com')
    assert new_user.is_technical_admin
    assert_not new_user.is_functional_admin
    assert new_user.is_user
  end

  test 'should not create user with invalid email' do
    user_count_before = User.count

    post users_url,
         params: { user: { firstname: 'Invalid', lastname: 'User', email: '' } },
         headers: { 'Authorization' => "Bearer #{@token}" },
         as: :json

    assert_response :not_acceptable
    assert_equal user_count_before, User.count, "Should not create a user with invalid email"
  end

  # UPDATE tests
  test 'should update user' do
    ActionMailer::Base.deliveries.clear

    patch user_url(@user),
          params: { user: { firstname: 'Updated', lastname: 'Name' } },
          headers: { 'Authorization' => "Bearer #{@token}" },
          as: :json

    assert_response :success
    @user.reload
    assert_equal 'Updated', @user.firstname
    assert_equal 'Name', @user.lastname
  end

  test 'should update user access_type' do
    patch user_url(@user),
          params: {
            user: {
              access_type: ['functional']
            }
          },
          headers: { 'Authorization' => "Bearer #{@token}" },
          as: :json

    assert_response :success
    @user.reload
    assert_not @user.is_technical_admin
    assert @user.is_functional_admin
    assert_not @user.is_user
  end

  test 'should send email when updating locked user email' do
    @user.lock_access!
    ActionMailer::Base.deliveries.clear

    patch user_url(@user),
          params: { user: { email: 'newemail@example.com' } },
          headers: { 'Authorization' => "Bearer #{@token}" },
          as: :json

    assert_response :success
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'should not send email when updating unlocked user email' do
    @user.unlock_access!
    ActionMailer::Base.deliveries.clear

    patch user_url(@user),
          params: { user: { email: 'newemail2@example.com' } },
          headers: { 'Authorization' => "Bearer #{@token}" },
          as: :json

    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  # CHECK_UUID tests
  test 'should check valid uuid for locked user' do
    @user.lock_access!

    get "/users/unlock_access/#{@user.uuid}",
        as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @user.email, json_response['email']
  end

  test 'should check valid uuid with reset param for unlocked user' do
    @user.unlock_access!

    get "/users/unlock_access/#{@user.uuid}/true",
        as: :json

    assert_response :success
  end

  test 'should return not_found for invalid uuid' do
    get "/users/unlock_access/invalid-uuid",
        as: :json

    assert_response :not_found
  end

  test 'should return not_acceptable for unlocked user without reset param' do
    @user.unlock_access!

    get "/users/unlock_access/#{@user.uuid}",
        as: :json

    assert_response :not_acceptable
  end

  # PASSWORD_FORGOTTEN tests
  test 'should handle password forgotten for existing user' do
    @user.unlock_access!
    old_uuid = @user.uuid
    ActionMailer::Base.deliveries.clear

    post password_forgotten_users_url,
         params: { email: @user.email },
         as: :json

    assert_response :success
    @user.reload
    assert_not_equal old_uuid, @user.uuid
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'should return locked for locked user password forgotten' do
    @user.lock_access!

    post password_forgotten_users_url,
         params: { email: @user.email },
         as: :json

    assert_response :locked
  end

  test 'should return not_found for non-existent email' do
    post password_forgotten_users_url,
         params: { email: 'nonexistent@example.com' },
         as: :json

    assert_response :not_found
  end

  # CHANGE_PASSWORD tests
  test 'should change password with valid uuid and password' do
    @user.lock_access!

    put change_password_users_url,
        params: {
          id: @user.id,
          uuid: @user.uuid,
          password: 'NewPassword123-',
          password_confirmation: 'NewPassword123-'
        },
        as: :json

    assert_response :no_content
    @user.reload
    assert_not @user.access_locked?
  end

  test 'should not change password with mismatched confirmation' do
    @user.lock_access!

    put change_password_users_url,
        params: {
          id: @user.id,
          uuid: @user.uuid,
          password: 'NewPassword123-',
          password_confirmation: 'DifferentPassword123-'
        },
        as: :json

    assert_response :not_acceptable
    @user.reload
    assert @user.access_locked?
  end

  test 'should not change password with invalid uuid' do
    put change_password_users_url,
        params: {
          id: @user.id,
          uuid: 'wrong-uuid',
          password: 'NewPassword123-',
          password_confirmation: 'NewPassword123-'
        },
        as: :json

    assert_response :not_found
  end

  # DESTROY tests
  test 'should destroy user' do
    user_to_delete = create(:user)
    user_count_before = User.count

    delete user_url(user_to_delete),
           headers: { 'Authorization' => "Bearer #{@token}" },
           as: :json

    assert_response :no_content
    assert_equal user_count_before - 1, User.count, "Should delete exactly one user"
  end
end
