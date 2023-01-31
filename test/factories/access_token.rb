FactoryBot.define do
  factory :access_token, class: 'Doorkeeper::Application' do
    # application
    name { "PIA" }
    redirect_uri { "urn:ietf:wg:oauth:2.0:oob" }
    scopes { ["read", "write"] }
  end
end
