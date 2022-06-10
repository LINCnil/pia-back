require 'test_helper'

class MeasuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @measure = create(:measure)
    @pia = @measure.pia
  end

  test 'should get index' do
    get pia_measures_url(@pia), as: :json
    assert_response :success
  end

  test 'should create measure' do
    assert_difference('Measure.count') do
      post pia_measures_url(@pia), params: { measure: {} }, as: :json
    end

    assert_response 201
  end

  test 'should show measure' do
    get pia_measure_url(id: @measure.id, pia_id: @pia.id), as: :json
    assert_response :success
  end

  test 'should update measure' do
    patch pia_measure_url(id: @measure.id, pia_id: @pia.id), params: { measure: {} }, as: :json
    assert_response 200
  end

  test 'should destroy measure' do
    assert_difference('Measure.count', -1) do
      delete pia_measure_url(id: @measure.id, pia_id: @pia.id), as: :json
    end

    assert_response 204
  end
end
