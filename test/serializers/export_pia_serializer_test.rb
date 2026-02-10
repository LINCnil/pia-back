require 'test_helper'

class ExportPiaSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @pia = create(:pia)
  end

  test "serializes basic export pia attributes" do
    data = ExportPiaSerializer.render_as_hash(@pia)

    assert_equal @pia.id, data[:id]
    assert_equal @pia.status, data[:status]
    assert_equal @pia.name, data[:name]
    assert_equal @pia.author_name, data[:author_name]
    assert_equal @pia.evaluator_name, data[:evaluator_name]
    assert_equal @pia.validator_name, data[:validator_name]
    assert_equal @pia.dpo_status, data[:dpo_status]
    assert_equal @pia.dpo_opinion, data[:dpo_opinion]
    assert_equal @pia.concerned_people_opinion, data[:concerned_people_opinion]
    assert_equal @pia.concerned_people_status, data[:concerned_people_status]
    assert_equal @pia.rejection_reason, data[:rejection_reason]
    assert_equal @pia.applied_adjustments, data[:applied_adjustments]
    assert_equal @pia.created_at, data[:created_at]
    assert_equal @pia.updated_at, data[:updated_at]
  end

  test "serializes associated answers" do
    create(:answer, pia: @pia)
    data = ExportPiaSerializer.render_as_hash(@pia.reload)

    assert_includes data.keys, :answers
    assert_equal @pia.answers.count, data[:answers].length
  end

  test "serializes associated evaluations" do
    create(:evaluation, pia: @pia)
    data = ExportPiaSerializer.render_as_hash(@pia.reload)

    assert_includes data.keys, :evaluations
    assert_equal @pia.evaluations.count, data[:evaluations].length
  end

  test "serializes associated comments" do
    create(:comment, pia: @pia)
    data = ExportPiaSerializer.render_as_hash(@pia.reload)

    assert_includes data.keys, :comments
    assert_equal @pia.comments.count, data[:comments].length
  end

  test "serializes associated measures" do
    create(:measure, pia: @pia)
    data = ExportPiaSerializer.render_as_hash(@pia.reload)

    assert_includes data.keys, :measures
    assert_equal @pia.measures.count, data[:measures].length
  end

  test "does not serialize structure_id" do
    structure = create(:structure)
    pia = create(:pia, structure: structure)
    data = ExportPiaSerializer.render_as_hash(pia)

    refute_includes data.keys, :structure_id
  end

  test "does not serialize is_example" do
    data = ExportPiaSerializer.render_as_hash(@pia)

    refute_includes data.keys, :is_example
  end
end
