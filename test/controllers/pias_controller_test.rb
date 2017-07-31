require 'test_helper'

class PiasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pia = pias(:one)
  end

  test "should get index" do
    get pias_url, as: :json
    assert_response :success
  end

  test "should create pia" do
    assert_difference('Pia.count') do
      post pias_url, params: { pia: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show pia" do
    get pia_url(@pia), as: :json
    assert_response :success
  end

  test "should update pia" do
    patch pia_url(@pia), params: { pia: {  } }, as: :json
    assert_response 200
  end

  test "should destroy pia" do
    assert_difference('Pia.count', -1) do
      delete pia_url(@pia), as: :json
    end

    assert_response 204
  end
end
