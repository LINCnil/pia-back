require 'test_helper'

class RevisionSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @revision = create(:revision)
  end

  test "serializes basic revision attributes" do
    data = RevisionSerializer.render_as_hash(@revision)

    assert_equal @revision.id, data[:id]
    assert_equal @revision.pia_id, data[:pia_id]
    assert_equal @revision.export, data[:export]
    assert_equal @revision.created_at, data[:created_at]
  end
end
