require 'test_helper'

class MeasuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @measure = measures(:one)
  end

  test "should get index" do
    get measures_url, as: :json
    assert_response :success
  end

  test "should create measure" do
    assert_difference('Measure.count') do
      post measures_url, params: { measure: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show measure" do
    get measure_url(@measure), as: :json
    assert_response :success
  end

  test "should update measure" do
    patch measure_url(@measure), params: { measure: {  } }, as: :json
    assert_response 200
  end

  test "should destroy measure" do
    assert_difference('Measure.count', -1) do
      delete measure_url(@measure), as: :json
    end

    assert_response 204
  end
end
