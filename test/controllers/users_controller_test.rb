require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  # Every UsersController action is authorized with Pundit, which ApplicationController only includes when
  # ENABLE_AUTHENTICATION is set at boot.
  ApplicationController.include(Pundit::Authorization)

  EMAIL = 'jane.roe@example.com'.freeze
  GENERATED_PASSWORD = 'Generated-Passw0rd!'.freeze
  SUBMITTED_PASSWORD = 'Submitted-Passw0rd!'.freeze

  setup do
    @headers = { 'Authorization' => "Bearer #{doorkeeper_token}" }
    @mailer_defaults = ApplicationMailer.default_params
    # The sender address comes from credentials, which are not available in the test environment.
    ApplicationMailer.default from: 'noreply@example.com'
  end

  teardown do
    ApplicationMailer.default_params = @mailer_defaults
  end

  test 'should create a locked user' do
    assert_difference('User.count') do
      post users_url, params: user_params, headers: @headers, as: :json
    end

    assert_response :success
    user = User.find_by!(email: EMAIL)
    assert user.access_locked?
    assert_equal user.id, response.parsed_body['id']
    assert_equal %w[user], response.parsed_body['access_type']
    assert response.parsed_body['access_locked']
  end

  test 'should set the generated random password and ignore a submitted one' do
    with_random_password(GENERATED_PASSWORD) do
      post users_url,
           params: user_params(password: SUBMITTED_PASSWORD, password_confirmation: SUBMITTED_PASSWORD),
           headers: @headers,
           as: :json
    end

    assert_response :success
    user = User.find_by!(email: EMAIL)
    assert user.valid_password?(GENERATED_PASSWORD)
    assert_not user.valid_password?(SUBMITTED_PASSWORD)
  end

  test 'should email the activation code to the new user' do
    assert_emails 1 do
      post users_url, params: user_params, headers: @headers, as: :json
    end

    user = User.find_by!(email: EMAIL)
    mail = ActionMailer::Base.deliveries.last
    assert_equal [EMAIL], mail.to
    assert_includes mail.text_part.body.to_s, user.uuid
  end

  test 'should apply the requested access types' do
    post users_url, params: user_params(access_type: %w[technical functional]), headers: @headers, as: :json

    assert_response :success
    user = User.find_by!(email: EMAIL)
    assert user.is_technical_admin?
    assert user.is_functional_admin?
    assert_not user.is_user?
  end

  test 'should not create a user with an email already taken' do
    taken = FactoryBot.create(:user)

    assert_no_difference('User.count') do
      assert_no_emails do
        post users_url, params: user_params(email: taken.email), headers: @headers, as: :json
      end
    end

    assert_response :not_acceptable
    assert_includes response.parsed_body.keys, 'email'
  end

  test 'should not create a user without an access token' do
    assert_no_difference('User.count') do
      post users_url, params: user_params, as: :json
    end

    assert_response :unauthorized
  end

  private

  def user_params(**attributes)
    { user: { firstname: 'Jane', lastname: 'Roe', email: EMAIL, access_type: %w[user], **attributes } }
  end

  # Minitest 6 has no stub, so the singleton method is swapped by hand.
  def with_random_password(password)
    original = User.method(:random_password)
    User.define_singleton_method(:random_password) { |*, **| password }
    yield
  ensure
    User.define_singleton_method(:random_password, original)
  end
end
