module AuthentificationHelper
  class AppWithAuth
    attr_reader :doorkeeper_app
    attr_reader :auth_token

    def initialize
      @doorkeeper_app = FactoryBot.create(:access_token)
    end

    def sign_in_as_user user, url
      url = URI.parse(url)
      params = {
        email: user.email,
        password: user.password,
        grant_type: "password",
        client_id: @doorkeeper_app.uid,
        client_secret: @doorkeeper_app.secret
      }
      res = Net::HTTP.post_form(url, params)
      byebug

      @auth_token = JSON.parse(res.body)["access_token"]
    end
  end
end
