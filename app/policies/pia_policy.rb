class PiaPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    # return true if user is admin or user owner.user_pias .find_by(pia_id: record.id)
    (user.present? && user.is_functional_admin?) || record.user_pias.find_by(user_id: user.id).present? || record.is_example
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

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.present? && user.is_functional_admin?
        scope.all
      else
        scope.joins(:user_pias).merge(UserPia.where(user_id: user.id))
      end
    end
  end
end
