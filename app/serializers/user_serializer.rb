class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :email, :firstname, :lastname

  attribute :access_type do |user|
    data = []
    data << 'technical' if user.is_technical_admin
    data << "functional" if user.is_functional_admin
    data << "user" if user.is_user
    data
  end

  attribute :access_auth do |user|
    data = []

    data
  end
end
