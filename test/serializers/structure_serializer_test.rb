require 'test_helper'

class StructureSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @structure = create(:structure)
  end

  test "serializes basic structure attributes" do
    data = StructureSerializer.render_as_hash(@structure)

    assert_equal @structure.id, data[:id]
    assert_equal @structure.name, data[:name]
    assert_equal @structure.sector_name, data[:sector_name]
    assert_equal @structure.data, data[:data]
    assert_equal @structure.created_at, data[:created_at]
    assert_equal @structure.updated_at, data[:updated_at]
  end
end