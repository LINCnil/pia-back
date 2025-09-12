require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @user = create(:user)
  end

  test "serializes basic user attributes" do
    data = UserSerializer.new(@user)
                         .serializable_hash
                         .dig(:data, :attributes)

    assert_equal @user.id, data[:id]
    assert_equal @user.email, data[:email]
    assert_equal @user.firstname, data[:firstname]
    assert_equal @user.lastname, data[:lastname]
  end

  test "serializes user_pias association" do
    create(:user_pia, user: @user)
    data = UserSerializer.new(@user.reload)
                         .serializable_hash
                         .dig(:data, :attributes)

    assert_includes data.keys, :user_pias
    assert_equal @user.user_pias.to_a, data[:user_pias]
  end

  test "serializes access_type for technical admin only" do
    user = create(:user,
                  is_technical_admin: true,
                  is_functional_admin: false,
                  is_user: false)

    data = UserSerializer.new(user)
                         .serializable_hash
                         .dig(:data, :attributes)

    assert_includes data[:access_type], 'technical'
    refute_includes data[:access_type], 'functional'
    refute_includes data[:access_type], 'user'
  end

  test "serializes access_type for functional admin only" do
    user = create(:user,
                  is_technical_admin: false,
                  is_functional_admin: true,
                  is_user: false)

    data = UserSerializer.new(user)
                         .serializable_hash
                         .dig(:data, :attributes)

    refute_includes data[:access_type], 'technical'
    assert_includes data[:access_type], 'functional'
    refute_includes data[:access_type], 'user'
  end

  test "serializes access_type for regular user only" do
    user = create(:user,
                  is_technical_admin: false,
                  is_functional_admin: false,
                  is_user: true)

    data = UserSerializer.new(user)
                         .serializable_hash
                         .dig(:data, :attributes)

    refute_includes data[:access_type], 'technical'
    refute_includes data[:access_type], 'functional'
    assert_includes data[:access_type], 'user'
  end

  test "serializes access_type for multiple roles" do
    user = create(:user,
                  is_technical_admin: true,
                  is_functional_admin: true,
                  is_user: true)

    data = UserSerializer.new(user)
                         .serializable_hash
                         .dig(:data, :attributes)

    assert_includes data[:access_type], 'technical'
    assert_includes data[:access_type], 'functional'
    assert_includes data[:access_type], 'user'
  end

  test "serializes empty access_type when no roles are set" do
    user = create(:user,
                  is_technical_admin: false,
                  is_functional_admin: false,
                  is_user: false)

    data = UserSerializer.new(user)
                         .serializable_hash
                         .dig(:data, :attributes)

    assert_empty data[:access_type]
  end

  test "serializes access_locked attribute when user is locked" do
    @user.lock_access!
    data = UserSerializer.new(@user.reload)
                         .serializable_hash
                         .dig(:data, :attributes)

    assert_equal true, data[:access_locked]
  end

  test "serializes access_locked attribute when user is not locked" do
    data = UserSerializer.new(@user)
                         .serializable_hash
                         .dig(:data, :attributes)

    assert_equal false, data[:access_locked]
  end

  test "does not serialize uuid attribute" do
    data = UserSerializer.new(@user)
                         .serializable_hash
                         .dig(:data, :attributes)

    refute_includes data.keys, :uuid
  end
end
