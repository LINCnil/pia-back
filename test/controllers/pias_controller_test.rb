require 'test_helper'

class PiasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pia = create(:pia)
  end

  test 'should get index' do
    get pias_url, as: :json
    assert_response :success
  end

  test 'should create pia' do
    pia_build = build(:pia)
    assert_difference('Pia.count') do
      post pias_url, params: { pia: { name: 'PIA' } }, as: :json
    end

    assert_response 201
  end

  test 'should show pia' do
    get pia_url(@pia), as: :json
    assert_response :success
  end

  test 'should update pia' do
    patch pia_url(@pia), params: { pia: {} }, as: :json
    assert_response 200
  end

  test 'should destroy pia' do
    assert_difference('Pia.count', -1) do
      delete pia_url(@pia), as: :json
    end

    assert_response 204
  end

  test 'should duplicate pia' do
    assert_difference('Pia.where(name: "PIA ONE").count') do
      post duplicate_pia_url(@pia)
    end
  end
end
