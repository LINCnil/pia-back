require 'test_helper'

class KnowledgeBaseTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    knowledge_base = build(:knowledge_base)
    assert knowledge_base.valid?
  end

  test "should require name" do
    knowledge_base = build(:knowledge_base, name: nil)
    assert_not knowledge_base.valid?
    assert_includes knowledge_base.errors[:name], "can't be blank"
  end

  test "should require author" do
    knowledge_base = build(:knowledge_base, author: nil)
    assert_not knowledge_base.valid?
    assert_includes knowledge_base.errors[:author], "can't be blank"
  end

  test "should require contributors" do
    knowledge_base = build(:knowledge_base, contributors: nil)
    assert_not knowledge_base.valid?
    assert_includes knowledge_base.errors[:contributors], "can't be blank"
  end

  test "should have many knowledges" do
    knowledge_base = create(:knowledge_base)
    create(:knowledge, knowledge_base: knowledge_base)
    create(:knowledge, knowledge_base: knowledge_base)
    assert_equal 2, knowledge_base.knowledges.count
  end

  test "should destroy dependent knowledges" do
    knowledge_base = create(:knowledge_base)
    create(:knowledge, knowledge_base: knowledge_base)
    create(:knowledge, knowledge_base: knowledge_base)

    assert_difference 'Knowledge.count', -2 do
      knowledge_base.destroy
    end
  end

  test "should sanitize name after initialize" do
    knowledge_base = KnowledgeBase.new(name: '<script>alert("xss")</script>Hello')
    assert_not_includes knowledge_base.name, '<script>'
  end

  test "should sanitize author after initialize" do
    knowledge_base = KnowledgeBase.new(author: '<script>alert("xss")</script>Hello')
    assert_not_includes knowledge_base.author, '<script>'
  end

  test "should sanitize contributors after initialize" do
    knowledge_base = KnowledgeBase.new(contributors: '<script>alert("xss")</script>Hello')
    assert_not_includes knowledge_base.contributors, '<script>'
  end
end
