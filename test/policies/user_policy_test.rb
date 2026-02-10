require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @technical_admin = create(:user, is_technical_admin: true, is_functional_admin: false, is_user: true)
    @functional_admin = create(:user, is_functional_admin: true, is_technical_admin: false, is_user: true)
    @both_admin = create(:user, is_technical_admin: true, is_functional_admin: true, is_user: true)
    @regular_user = create(:user, is_technical_admin: false, is_functional_admin: false, is_user: true)
    @target_user = create(:user)
  end

  # index? tests
  test "index? allows technical admin" do
    policy = UserPolicy.new(@technical_admin, @target_user)
    assert policy.index?
  end

  test "index? allows functional admin" do
    policy = UserPolicy.new(@functional_admin, @target_user)
    assert policy.index?
  end

  test "index? allows user with both admin roles" do
    policy = UserPolicy.new(@both_admin, @target_user)
    assert policy.index?
  end

  test "index? denies regular user" do
    policy = UserPolicy.new(@regular_user, @target_user)
    assert_not policy.index?
  end

  # create? tests
  test "create? allows technical admin" do
    policy = UserPolicy.new(@technical_admin, User)
    assert policy.create?
  end

  test "create? denies functional admin" do
    policy = UserPolicy.new(@functional_admin, User)
    assert_not policy.create?
  end

  test "create? denies regular user" do
    policy = UserPolicy.new(@regular_user, User)
    assert_not policy.create?
  end

  # update? tests
  test "update? allows technical admin" do
    policy = UserPolicy.new(@technical_admin, @target_user)
    assert policy.update?
  end

  test "update? denies functional admin" do
    policy = UserPolicy.new(@functional_admin, @target_user)
    assert_not policy.update?
  end

  test "update? denies regular user" do
    policy = UserPolicy.new(@regular_user, @target_user)
    assert_not policy.update?
  end

  # destroy? tests
  test "destroy? allows technical admin" do
    policy = UserPolicy.new(@technical_admin, @target_user)
    assert policy.destroy?
  end

  test "destroy? denies functional admin" do
    policy = UserPolicy.new(@functional_admin, @target_user)
    assert_not policy.destroy?
  end

  test "destroy? denies regular user" do
    policy = UserPolicy.new(@regular_user, @target_user)
    assert_not policy.destroy?
  end

  # Edge cases
  test "all actions allow user with both admin roles" do
    policy = UserPolicy.new(@both_admin, @target_user)
    assert policy.index?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end
end
