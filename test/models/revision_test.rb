require 'test_helper'

class RevisionTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    revision = build(:revision)
    assert revision.valid?
  end

  test "should belong to pia" do
    revision = create(:revision)
    assert_instance_of Pia, revision.pia
  end

  test "should require pia" do
    revision = build(:revision, pia: nil)
    assert_not revision.valid?
    assert_includes revision.errors[:pia], "can't be blank"
  end

  test "should require export" do
    revision = build(:revision, export: nil)
    assert_not revision.valid?
    assert_includes revision.errors[:export], "can't be blank"
  end
end
