class PiaPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def example?
    user.present?
  end

  def create?
    user.present? && user.is_functional_admin?
  end

  def update?
    user.present? && user.is_functional_admin?
  end

  def destroy?
    user.present? && user.is_functional_admin?
  end

  def duplicate?
    user.present? && user.is_functional_admin?
  end

  def import?
    user.present? && user.is_functional_admin?
  end
end
