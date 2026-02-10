require 'test_helper'

class CommentSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @comment = create(:comment)
  end

  test "serializes basic comment attributes" do
    data = CommentSerializer.render_as_hash(@comment)

    assert_equal @comment.id, data[:id]
    assert_equal @comment.pia_id, data[:pia_id]
    assert_equal @comment.description, data[:description]
    assert_equal @comment.reference_to, data[:reference_to]
    assert_equal @comment.for_measure, data[:for_measure]
    assert_equal @comment.user, data[:user]
    assert_equal @comment.created_at, data[:created_at]
    assert_equal @comment.updated_at, data[:updated_at]
  end

  test "serializes comment with user" do
    user = create(:user)
    comment = create(:comment, user: user)
    data = CommentSerializer.render_as_hash(comment)

    assert_equal user, data[:user]
  end
end
