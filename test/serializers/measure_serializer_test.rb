require 'test_helper'

class MeasureSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @measure = create(:measure)
  end

  test "serializes basic measure attributes" do
    data = MeasureSerializer.render_as_hash(@measure)

    assert_equal @measure.id, data[:id]
    assert_equal @measure.pia_id, data[:pia_id]
    assert_equal @measure.title, data[:title]
    assert_equal @measure.content, data[:content]
    assert_equal @measure.placeholder, data[:placeholder]
    assert_equal @measure.lock_version, data[:lock_version]
  end
end