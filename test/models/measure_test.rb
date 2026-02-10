require 'test_helper'

class MeasureTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    measure = build(:measure)
    assert measure.valid?
  end

  test "should belong to pia" do
    measure = create(:measure)
    assert_instance_of Pia, measure.pia
  end

  test "should sanitize title after initialize" do
    measure = Measure.new(title: '<script>alert("xss")</script>Hello')
    assert_not_includes measure.title, '<script>'
  end

  test "should sanitize content after initialize" do
    measure = Measure.new(content: '<script>alert("xss")</script>Hello')
    assert_not_includes measure.content, '<script>'
  end

  test "should sanitize placeholder after initialize" do
    measure = Measure.new(placeholder: '<script>alert("xss")</script>Hello')
    assert_not_includes measure.placeholder, '<script>'
  end
end
