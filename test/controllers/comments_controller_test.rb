require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comment = create(:comment)
    @pia = @comment.pia
  end

  test 'should get index' do
    get pia_comments_url(@pia), as: :json
    assert_response :success
  end

  test 'should create comment' do
    assert_difference('Comment.count') do
      post pia_comments_url(@pia), params: { comment: { reference_to: '1.1.2' } }, as: :json
    end

    assert_response 201
  end

  test 'should show comment' do
    get pia_comment_url(id: @comment.id, pia_id: @pia.id), as: :json
    assert_response :success
  end

  test 'should update comment' do
    patch pia_comment_url(id: @comment.id, pia_id: @pia.id), params: { comment: {} }, as: :json
    assert_response 200
  end

  test 'should destroy comment' do
    assert_difference('Comment.count', -1) do
      delete pia_comment_url(id: @comment.id, pia_id: @pia.id), as: :json
    end

    assert_response 204
  end
end
