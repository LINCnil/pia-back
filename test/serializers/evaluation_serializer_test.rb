require 'test_helper'

class EvaluationSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @evaluation = create(:evaluation)
  end

  test "serializes basic evaluation attributes" do
    data = EvaluationSerializer.render_as_hash(@evaluation)

    assert_equal @evaluation.id, data[:id]
    assert_equal @evaluation.pia_id, data[:pia_id]
    assert_equal @evaluation.status, data[:status]
    assert_equal @evaluation.reference_to, data[:reference_to]
    assert_equal @evaluation.action_plan_comment, data[:action_plan_comment]
    assert_equal @evaluation.evaluation_comment, data[:evaluation_comment]
    assert_equal @evaluation.evaluation_date, data[:evaluation_date]
    assert_equal @evaluation.gauges, data[:gauges]
    assert_equal @evaluation.estimated_implementation_date, data[:estimated_implementation_date]
    assert_equal @evaluation.person_in_charge, data[:person_in_charge]
    assert_equal @evaluation.global_status, data[:global_status]
    assert_equal @evaluation.created_at, data[:created_at]
    assert_equal @evaluation.updated_at, data[:updated_at]
  end
end
