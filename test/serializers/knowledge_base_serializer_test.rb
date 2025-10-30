require 'test_helper'

class KnowledgeBaseSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @knowledge_base = create(:knowledge_base)
  end

  test "serializes basic knowledge base attributes" do
    data = KnowledgeBaseSerializer.render_as_hash(@knowledge_base)

    assert_equal @knowledge_base.id, data[:id]
    assert_equal @knowledge_base.name, data[:name]
    assert_equal @knowledge_base.author, data[:author]
    assert_equal @knowledge_base.contributors, data[:contributors]
    assert_equal @knowledge_base.is_example, data[:is_example]
    assert_equal @knowledge_base.lock_version, data[:lock_version]
    assert_equal @knowledge_base.created_at, data[:created_at]
    assert_equal @knowledge_base.updated_at, data[:updated_at]
  end
end
