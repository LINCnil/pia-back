require 'test_helper'

class KnowledgeTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    knowledge = build(:knowledge)
    assert knowledge.valid?
  end

  test "should belong to knowledge_base" do
    knowledge = create(:knowledge)
    assert_instance_of KnowledgeBase, knowledge.knowledge_base
  end

  test "should require name" do
    knowledge = build(:knowledge, name: nil)
    assert_not knowledge.valid?
    assert_includes knowledge.errors[:name], "can't be blank"
  end

  test "should require knowledge_base" do
    knowledge = build(:knowledge, knowledge_base: nil)
    assert_not knowledge.valid?
    assert_includes knowledge.errors[:knowledge_base], "can't be blank"
  end

  test "should sanitize name after initialize" do
    knowledge = Knowledge.new(name: '<script>alert("xss")</script>Hello')
    assert_not_includes knowledge.name, '<script>'
  end
end
