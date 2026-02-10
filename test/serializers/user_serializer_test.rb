require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @user = create(:user)
  end

  test "serializes basic user attributes" do
    data = UserSerializer.render_as_hash(@user)

    assert_equal @user.id, data[:id]
    assert_equal @user.email, data[:email]
    assert_equal @user.firstname, data[:firstname]
    assert_equal @user.lastname, data[:lastname]
  end

  test "serializes access_type for technical admin only" do
    user = create(:user,
                  is_technical_admin: true,
                  is_functional_admin: false,
                  is_user: false)

    data = UserSerializer.render_as_hash(user)

    assert_includes data[:access_type], 'technical'
    refute_includes data[:access_type], 'functional'
    refute_includes data[:access_type], 'user'
  end

  test "serializes access_type for functional admin only" do
    user = create(:user,
                  is_technical_admin: false,
                  is_functional_admin: true,
                  is_user: false)

    data = UserSerializer.render_as_hash(user)

    refute_includes data[:access_type], 'technical'
    assert_includes data[:access_type], 'functional'
    refute_includes data[:access_type], 'user'
  end

  test "serializes access_type for regular user only" do
    user = create(:user,
                  is_technical_admin: false,
                  is_functional_admin: false,
                  is_user: true)

    data = UserSerializer.render_as_hash(user)

    refute_includes data[:access_type], 'technical'
    refute_includes data[:access_type], 'functional'
    assert_includes data[:access_type], 'user'
  end

  test "serializes access_type for multiple roles" do
    user = create(:user,
                  is_technical_admin: true,
                  is_functional_admin: true,
                  is_user: true)

    data = UserSerializer.render_as_hash(user)

    assert_includes data[:access_type], 'technical'
    assert_includes data[:access_type], 'functional'
    assert_includes data[:access_type], 'user'
  end

  test "serializes empty access_type when no roles are set" do
    user = create(:user,
                  is_technical_admin: false,
                  is_functional_admin: false,
                  is_user: false)

    data = UserSerializer.render_as_hash(user)

    assert_empty data[:access_type]
  end

  test "serializes access_locked attribute when user is locked" do
    @user.lock_access!
    data = UserSerializer.render_as_hash(@user.reload)

    assert_equal true, data[:access_locked]
  end

  test "serializes access_locked attribute when user is not locked" do
    data = UserSerializer.render_as_hash(@user)

    assert_equal false, data[:access_locked]
  end

  test "does not serialize uuid attribute" do
    data = UserSerializer.render_as_hash(@user)

    refute_includes data.keys, :uuid
  end

  test "serializes user_pias as array of pia_ids" do
    pia1 = create(:pia)
    pia2 = create(:pia)
    create(:user_pia, user: @user, pia: pia1)
    create(:user_pia, user: @user, pia: pia2)

    data = UserSerializer.render_as_hash(@user.reload)

    assert_includes data.keys, :user_pias
    assert_equal 2, data[:user_pias].length
    assert_includes data[:user_pias], pia1.id
    assert_includes data[:user_pias], pia2.id
  end

  test "restricted view excludes access_type" do
    data = UserSerializer.render_as_hash(@user, view: :restricted)

    refute_includes data.keys, :access_type
  end

  test "restricted view excludes user_pias" do
    data = UserSerializer.render_as_hash(@user, view: :restricted)

    refute_includes data.keys, :user_pias
  end

  test "restricted view excludes access_locked" do
    data = UserSerializer.render_as_hash(@user, view: :restricted)

    refute_includes data.keys, :access_locked
  end

  test "restricted view includes basic fields" do
    data = UserSerializer.render_as_hash(@user, view: :restricted)

    assert_includes data.keys, :id
    assert_includes data.keys, :email
    assert_includes data.keys, :firstname
    assert_includes data.keys, :lastname
  end
end
