require 'test_helper'

class StructuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @structure = create(:structure)
  end

  test 'should get index' do
    get structures_url, as: :json
    assert_response :success
  end

  test 'should create structure' do
    structure_build = build(:structure)
    assert_difference('Structure.count') do
      post structures_url, params: { structure: { name: 'Structure 1', sector_name: 'Structure Sector Name 1', data: '{"sections":[]}' } },
                           as: :json
    end

    assert_response 201
  end

  test 'should show structure' do
    get structure_url(@structure), as: :json
    assert_response :success
  end

  test 'should update structure' do
    patch structure_url(@structure), params: { structure: { name: 'Structure 1 updated' } }, as: :json
    assert_response 200
  end

  test 'should destroy structure' do
    assert_difference('Structure.count', -1) do
      delete structure_url(@structure), as: :json
    end

    assert_response 204
  end
end
