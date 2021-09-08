class UserPolicy < ApplicationPolicy
  def index?
    user.is_technical_admin?
  end

  def create?
    user.is_technical_admin?
  end

  def update?
    user.is_technical_admin?
  end

  def destroy?
    user.is_technical_admin?
  end
end