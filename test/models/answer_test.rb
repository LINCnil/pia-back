require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    answer = build(:answer)
    assert answer.valid?
  end

  test "should belong to pia" do
    answer = create(:answer)
    assert_instance_of Pia, answer.pia
  end

  test "should require reference_to" do
    answer = build(:answer, reference_to: nil)
    assert_not answer.valid?
    assert_includes answer.errors[:reference_to], "can't be blank"
  end

  test "should sanitize data text after initialize" do
    answer = Answer.new(data: { 'text' => '<script>alert("xss")</script>Hello' })
    assert_not_includes answer.data['text'], '<script>'
  end
end
