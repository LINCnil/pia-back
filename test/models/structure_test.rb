require 'test_helper'

class StructureTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    structure = build(:structure)
    assert structure.valid?
  end

  test "should have many pias" do
    structure = create(:structure)
    create(:pia, structure: structure)
    create(:pia, structure: structure)
    assert_equal 2, structure.pias.count
  end

  test "should nullify pias on destroy" do
    structure = create(:structure)
    pia = create(:pia, structure: structure)

    structure.destroy
    pia.reload

    assert_nil pia.structure_id
  end

  test "should sanitize name after initialize" do
    structure = Structure.new(name: '<script>alert("xss")</script>Hello')
    assert_not_includes structure.name, '<script>'
  end

  test "should sanitize sector_name after initialize" do
    structure = Structure.new(sector_name: '<script>alert("xss")</script>Hello')
    assert_not_includes structure.sector_name, '<script>'
  end
end
