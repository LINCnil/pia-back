require 'test_helper'

class UserPiaTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    user_pia = build(:user_pia)
    assert user_pia.valid?
  end

  test "should belong to user" do
    user_pia = create(:user_pia)
    assert_instance_of User, user_pia.user
  end

  test "should belong to pia" do
    user_pia = create(:user_pia)
    assert_instance_of Pia, user_pia.pia
  end

  test "should have role enum" do
    user_pia = create(:user_pia, role: :guest)
    assert_equal 'guest', user_pia.role
    
    user_pia.role = :author
    assert_equal 'author', user_pia.role
    
    user_pia.role = :evaluator
    assert_equal 'evaluator', user_pia.role
    
    user_pia.role = :validator
    assert_equal 'validator', user_pia.role
  end

  test "should use users_pias table name" do
    assert_equal 'users_pias', UserPia.table_name
  end
end
