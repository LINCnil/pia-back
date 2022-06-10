require 'test_helper'

class EvaluationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @evaluation = create(:evaluation)
    @pia = @evaluation.pia
  end

  test 'should get index' do
    get pia_evaluations_url(@pia), as: :json
    assert_response :success
  end

  test 'should create evaluation' do
    assert_difference('Evaluation.count') do
      post pia_evaluations_url(@pia), params: { evaluation: { reference_to: '1.1.2', evaluation_infos: '{}' } }, as: :json
    end

    assert_response 201
  end

  test 'should show evaluation' do
    get pia_evaluation_url(id: @evaluation.id, pia_id: @pia.id), as: :json
    assert_response :success
  end

  test 'should update evaluation' do
    patch pia_evaluation_url(id: @evaluation.id, pia_id: @pia.id), params: { evaluation: {} }, as: :json
    assert_response 200
  end

  test 'should destroy eva' do
    assert_difference('Evaluation.count', -1) do
      delete pia_evaluation_url(id: @evaluation.id, pia_id: @pia.id), as: :json
    end

    assert_response 204
  end
end
