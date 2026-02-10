require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    comment = build(:comment)
    assert comment.valid?
  end

  test "should belong to pia" do
    comment = create(:comment)
    assert_instance_of Pia, comment.pia
  end

  test "should belong to user optionally" do
    comment = create(:comment, user: nil)
    assert comment.valid?
    assert_nil comment.user
  end

  test "should require reference_to" do
    comment = build(:comment, reference_to: nil)
    assert_not comment.valid?
    assert_includes comment.errors[:reference_to], "can't be blank"
  end

  test "should sanitize description after initialize" do
    comment = Comment.new(description: '<script>alert("xss")</script>Hello')
    assert_not_includes comment.description, '<script>'
  end
end
