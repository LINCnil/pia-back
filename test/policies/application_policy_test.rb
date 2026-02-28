require 'test_helper'

class ApplicationPolicyTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @user = create(:user)
    @record = create(:pia)
  end

  test "index? returns false by default" do
    policy = ApplicationPolicy.new(@user, @record)
    assert_not policy.index?
  end

  test "show? returns false by default" do
    policy = ApplicationPolicy.new(@user, @record)
    assert_not policy.show?
  end

  test "create? returns false by default" do
    policy = ApplicationPolicy.new(@user, @record)
    assert_not policy.create?
  end

  test "new? delegates to create?" do
    policy = ApplicationPolicy.new(@user, @record)
    assert_equal policy.create?, policy.new?
  end

  test "update? returns false by default" do
    policy = ApplicationPolicy.new(@user, @record)
    assert_not policy.update?
  end

  test "edit? delegates to update?" do
    policy = ApplicationPolicy.new(@user, @record)
    assert_equal policy.update?, policy.edit?
  end

  test "destroy? returns false by default" do
    policy = ApplicationPolicy.new(@user, @record)
    assert_not policy.destroy?
  end

  test "Scope#resolve returns all records by default" do
    create_list(:pia, 3)
    scope = ApplicationPolicy::Scope.new(@user, Pia.all)
    assert_equal Pia.count, scope.resolve.count
  end
end
