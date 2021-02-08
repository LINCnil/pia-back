module CustomTokenResponse
  def body
    user = User.find(@token.resource_owner_id)
    additional_data = {
      firstname: user.firstname,
      lastname: user.lastname,
      email: user.email,
      technical: user.is_technical_admin,
      functional: user.is_functional_admin,
      user: user.is_user,
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