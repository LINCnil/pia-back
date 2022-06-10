require 'test_helper'

class AnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @answer = create(:answer)
    @pia = @answer.pia
  end

  test 'should get index' do
    get pia_answers_url(@pia), as: :json
    assert_response :success
  end

  test 'should create answer' do
    assert_difference('Answer.count') do
      post pia_answers_url(@pia), params: { answer: { reference_to: '1.1.2' } }, as: :json
    end

    assert_response 201
  end

  test 'should show answer' do
    get pia_answer_url(id: @answer.id, pia_id: @pia.id), as: :json
    assert_response :success
  end

  test 'should update answer' do
    patch pia_answer_url(id: @answer, pia_id: @pia.id), params: { answer: {} }, as: :json
    assert_response 200
  end

  test 'should destroy answer' do
    assert_difference('Answer.count', -1) do
      delete pia_answer_url(id: @answer.id, pia_id: @pia.id), as: :json
    end

    assert_response 204
  end
end
