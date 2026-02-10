require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "should be valid with valid attributes" do
    user = build(:user)
    assert user.valid?
  end

  test "should generate uuid before validation" do
    user = build(:user, uuid: nil)
    user.valid?
    assert_not_nil user.uuid
  end

  test "should require password confirmation on create" do
    user = build(:user, password_confirmation: nil)
    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "can't be blank"
  end

  test "should require password confirmation on update when password is present" do
    user = create(:user)
    user.password = 'NewPassword123-'
    user.password_confirmation = nil
    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "can't be blank"
  end

  test "should not require password confirmation on update when password is blank" do
    user = create(:user)
    user.email = 'newemail@example.com'
    user.password = nil
    user.password_confirmation = nil
    assert user.valid?
  end

  test "should validate login uniqueness when present" do
    user1 = create(:user, login: 'testuser')
    user2 = build(:user, login: 'testuser')
    assert_not user2.valid?
    assert_includes user2.errors[:login], "has already been taken"
  end

  test "should allow duplicate nil logins" do
    create(:user, login: nil)
    user2 = build(:user, login: nil)
    assert user2.valid?
  end

  test "should have many user_pias" do
    user = create(:user)
    create(:user_pia, user: user)
    create(:user_pia, user: user)
    assert_equal 2, user.user_pias.count
  end

  test "should update user_pias infos after update" do
    user = create(:user, firstname: 'John', lastname: 'Doe')
    pia = create(:pia)
    create(:user_pia, user: user, pia: pia, role: :author)

    user.update(firstname: 'Jane', lastname: 'Smith')
    pia.reload

    assert_equal 'Jane Smith', pia.author_name
  end

  test "should update evaluator name when user is evaluator" do
    user = create(:user, firstname: 'John', lastname: 'Doe')
    pia = create(:pia)
    create(:user_pia, user: user, pia: pia, role: :evaluator)

    user.update(firstname: 'Jane', lastname: 'Smith')
    pia.reload

    assert_equal 'Jane Smith', pia.evaluator_name
  end

  test "should update validator name when user is validator" do
    user = create(:user, firstname: 'John', lastname: 'Doe')
    pia = create(:pia)
    create(:user_pia, user: user, pia: pia, role: :validator)

    user.update(firstname: 'Jane', lastname: 'Smith')
    pia.reload

    assert_equal 'Jane Smith', pia.validator_name
  end

  test "should destroy dependent user_pias" do
    user = create(:user)
    create(:user_pia, user: user)
    create(:user_pia, user: user)

    assert_difference 'UserPia.count', -2 do
      user.destroy
    end
  end

  test "should destroy dependent access grants" do
    user = create(:user)
    assert_difference 'user.access_grants.count', 0 do
      user.destroy
    end
  end

  test "should destroy dependent access tokens" do
    user = create(:user)
    assert_difference 'user.access_tokens.count', 0 do
      user.destroy
    end
  end
end
