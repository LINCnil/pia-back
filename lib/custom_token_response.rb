module CustomTokenResponse
  def body
    user = User.find(@token.resource_owner_id)
    access_type = []
    access_type << "technical" if user.is_technical_admin
    access_type << "functional" if user.is_functional_admin
    access_type << "user" if user.is_user
    additional_data = {
      firstname: user.firstname,
      lastname: user.lastname,
      email: user.email,
      access_type: access_type,
      access_auth: [
        {
          id: nil,
          roles: [],
        }
      ]
    }
    super.merge(additional_data)
  end
end