require 'test_helper'

class KnowledgeSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @knowledge = create(:knowledge)
  end

  test "serializes basic knowledge attributes" do
    data = KnowledgeSerializer.render_as_hash(@knowledge)

    assert_equal @knowledge.id, data[:id]
    assert_equal @knowledge.name, data[:name]
    assert_equal @knowledge.slug, data[:slug]
    assert_equal @knowledge.filters, data[:filters]
    assert_equal @knowledge.category, data[:category]
    assert_equal @knowledge.placeholder, data[:placeholder]
    assert_equal @knowledge.description, data[:description]
    assert_equal @knowledge.items, data[:items]
    assert_equal @knowledge.lock_version, data[:lock_version]
    assert_equal @knowledge.created_at, data[:created_at]
    assert_equal @knowledge.updated_at, data[:updated_at]
  end
end