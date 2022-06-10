require 'test_helper'

class RevisionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @revision = create(:revision)
    @pia = @revision.pia
  end

  test 'should get index' do
    get pia_revisions_url(@pia), as: :json
    assert_response :success
  end

  test 'should create revision' do
    assert_difference('Revision.count') do
      post pia_revisions_url(@pia), params: { revision: { export: { pia: [] }.to_json } }, as: :json
    end

    assert_response 201
  end

  test 'should show revision' do
    get pia_revision_url(id: @revision, pia_id: @pia.id), as: :json
    assert_response :success
  end

  test 'should destroy revision' do
    assert_difference('Revision.count', -1) do
      delete pia_revision_url(id: @revision, pia_id: @pia.id), as: :json
    end

    assert_response 204
  end
end
