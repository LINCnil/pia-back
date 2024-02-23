module AuthorizationHelper
  def auth_tokens_for_user(user, auth)
    # The argument 'user' should be a hash that includes the params 'email' and 'password'.
    post '/oauth/token',
    params: {
      email: user.email,
      password: user.password,
      grant_type: "password",
      client_id: auth.uid,
      client_secret: auth.secret
    }
    JSON.parse(response.body)
  end
end
