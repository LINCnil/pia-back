# frozen_string_literal: true

class UserSerializer < Blueprinter::Base
  identifier :id
  fields :email, :firstname, :lastname

  field :access_type do |user|
    data = []
    data << 'technical' if user.is_technical_admin?
    data << 'functional' if user.is_functional_admin?
    data << 'user' if user.is_user?
    data
  end

  field :access_locked do |user|
    user.access_locked?
  end

  view :restricted do
    excludes :access_type, :user_pias, :access_locked
  end
end
