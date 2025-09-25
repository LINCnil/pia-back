require 'test_helper'

class PiaSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @pia = create(:pia)
  end

  test "serializes basic pia attributes" do
    data = PiaSerializer.render_as_hash(@pia)

    assert_equal @pia.id, data[:id]
    assert_equal @pia.status, data[:status]
    assert_equal @pia.name, data[:name]
    assert_equal @pia.author_name, data[:author_name]
    assert_equal @pia.evaluator_name, data[:evaluator_name]
    assert_equal @pia.validator_name, data[:validator_name]
    assert_equal @pia.dpo_status, data[:dpo_status]
    assert_equal @pia.dpo_opinion, data[:dpo_opinion]
    assert_equal @pia.dpos_names, data[:dpos_names]
    assert_equal @pia.people_names, data[:people_names]
    assert_equal @pia.concerned_people_opinion, data[:concerned_people_opinion]
    assert_equal @pia.concerned_people_status, data[:concerned_people_status]
    assert_equal @pia.rejection_reason, data[:rejection_reason]
    assert_equal @pia.applied_adjustments, data[:applied_adjustments]
    assert_equal @pia.is_example, data[:is_example]
    assert_equal @pia.created_at, data[:created_at]
    assert_equal @pia.updated_at, data[:updated_at]
    assert_equal @pia.concerned_people_searched_opinion, data[:concerned_people_searched_opinion]
    assert_equal @pia.concerned_people_searched_content, data[:concerned_people_searched_content]
    assert_equal @pia.structure_id, data[:structure_id]
    assert_equal @pia.structure_name, data[:structure_name]
    assert_equal @pia.structure_sector_name, data[:structure_sector_name]
    assert_equal @pia.structure_data, data[:structure_data]
    assert_equal @pia.category, data[:category]
    assert_equal @pia.progress, data[:progress]
    assert_equal @pia.lock_version, data[:lock_version]
  end

  test "serializes is_archive as integer" do
    @pia.update(is_archive: true)
    data = PiaSerializer.render_as_hash(@pia)

    assert_equal 1, data[:is_archive]

    @pia.update(is_archive: false)
    data = PiaSerializer.render_as_hash(@pia)

    assert_equal 0, data[:is_archive]
  end

  test "serializes user_pias association with user and role" do
    user = create(:user)
    create(:user_pia, user: user, pia: @pia, role: 'author')
    data = PiaSerializer.render_as_hash(@pia.reload)

    assert_includes data.keys, :user_pias
    assert_equal 1, data[:user_pias].length
    assert_includes data[:user_pias][0].keys, :user
    assert_includes data[:user_pias][0].keys, :role
    assert_equal 'author', data[:user_pias][0][:role]
  end
end
