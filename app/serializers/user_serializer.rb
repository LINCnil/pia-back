class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :email, :firstname, :lastname, :user_pias

  attribute :access_type do |user|
    data = []
    data << 'technical' if user.is_technical_admin
    data << 'functional' if user.is_functional_admin
    data << 'user' if user.is_user
    data
  end

  attribute :access_locked do |user|
    user.access_locked?
  end
end
