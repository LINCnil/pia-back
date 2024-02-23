require 'test_helper'
require 'authorization_helper'

class PiasControllerTest < ActionDispatch::IntegrationTest
  include AuthorizationHelper
  setup do
    @pia = FactoryBot.create(:pia)
    @doorkeeper_token = doorkeeper_token
    if ENV['ENABLE_AUTHENTICATION'].present?
      @auth = FactoryBot.create(:access_token)
      @admin = FactoryBot.create(:user_admin, identifier: "admin")
      @auth_tokens = auth_tokens_for_user(@admin, @auth)

      @doorkeeper_token = @auth_tokens['access_token']
      # create users
      @user_functional = FactoryBot.create(:user, identifier: "functional")
      @user_user = FactoryBot.create(:user, identifier: "user")
      @user_user.lock_access!
    end
  end

  test 'should get index' do
    get pias_url, headers: { 'Authorization' => "Bearer #{@doorkeeper_token}" }, as: :json
    assert_response :success
  end

  test 'should create pia' do
    pia_build = FactoryBot.build(:pia)
    assert_difference('Pia.count') do
      post pias_url, params: { pia: { name: 'PIA' } }, headers: { 'Authorization' => "Bearer #{@doorkeeper_token}" }, as: :json
    end

    assert_response 201
  end

  test 'should show pia' do
    get pia_url(@pia), headers: { 'Authorization' => "Bearer #{@doorkeeper_token}" }, as: :json
    assert_response :success
  end

  test 'should update pia' do
    pia_params = {}
    if ENV['ENABLE_AUTHENTICATION'].present?
      # assign users
      pia_params[:authors] = [@user_functional.id, @user_user.id].join(",")
      pia_params[:validators] = [@user_user.id].join(",")
    end

    patch pia_url(@pia), params: { pia: pia_params }, headers: { 'Authorization' => "Bearer #{@doorkeeper_token}" }, as: :json
    pia_response = JSON.parse(response.body)

    assert_response 200
    assert_equal pia_response["user_pias"].count, 3
  end

  test 'should destroy pia' do
    assert_difference('Pia.count', -1) do
      delete pia_url(@pia), headers: { 'Authorization' => "Bearer #{@doorkeeper_token}" }, as: :json
    end

    assert_response 204
  end

  test 'should duplicate pia' do
    assert_difference('Pia.count') do
      post duplicate_pia_url(@pia), headers: { 'Authorization' => "Bearer #{@doorkeeper_token}" }
    end
  end
end
