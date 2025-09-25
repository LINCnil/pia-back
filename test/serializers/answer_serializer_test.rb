require 'test_helper'

class AnswerSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @answer = create(:answer)
  end

  test "serializes basic answer attributes" do
    data = AnswerSerializer.render_as_hash(@answer)

    assert_equal @answer.id, data[:id]
    assert_equal @answer.pia_id, data[:pia_id]
    assert_equal @answer.reference_to, data[:reference_to]
    assert_equal @answer.data, data[:data]
    assert_equal @answer.lock_version, data[:lock_version]
    assert_equal @answer.created_at, data[:created_at]
    assert_equal @answer.updated_at, data[:updated_at]
  end
end