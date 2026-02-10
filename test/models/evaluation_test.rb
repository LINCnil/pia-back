require 'test_helper'

class EvaluationTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    evaluation = build(:evaluation)
    assert evaluation.valid?
  end

  test "should belong to pia" do
    evaluation = create(:evaluation)
    assert_instance_of Pia, evaluation.pia
  end

  test "should require reference_to" do
    evaluation = build(:evaluation, reference_to: nil)
    assert_not evaluation.valid?
    assert_includes evaluation.errors[:reference_to], "can't be blank"
  end

  test "should sanitize action_plan_comment after initialize" do
    evaluation = Evaluation.new(action_plan_comment: '<script>alert("xss")</script>Hello')
    assert_not_includes evaluation.action_plan_comment, '<script>'
  end

  test "should sanitize evaluation_comment after initialize" do
    evaluation = Evaluation.new(evaluation_comment: '<script>alert("xss")</script>Hello')
    assert_not_includes evaluation.evaluation_comment, '<script>'
  end

  test "should have evaluation_infos accessor" do
    evaluation = build(:evaluation)
    evaluation.evaluation_infos = { 'test' => 'value' }
    assert_equal({ 'test' => 'value' }, evaluation.evaluation_infos)
  end
end
