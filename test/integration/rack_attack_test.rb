require 'test_helper'

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    @previous_store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rack::Attack.cache.store = @previous_store
  end

  test 'returns JSON and retry time when OAuth requests exceed the limit' do
    travel_to Time.utc(2025, 1, 1, 0, 1) do
      100.times do
        post '/oauth/token'
        assert_not_equal 429, response.status
      end

      post '/oauth/token'
      assert_response :too_many_requests
      assert_equal 'application/json', response.media_type
      assert_equal '840', response.headers['Retry-After']
      assert_equal({ 'error' => 'Rate limit exceeded. Try again in 840 seconds.' }, response.parsed_body)

      travel 840.seconds
      post '/oauth/token'
      assert_not_equal 429, response.status
    end
  end

  test 'allows multiple successful OAuth logins from the same IP' do
    application = Doorkeeper::Application.create!(
      name: 'Rate limit test client',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      scopes: 'read write'
    )

    with_env('LDAP_ENABLED' => 'false') do
      6.times do
        user = FactoryBot.create(:user)
        post '/oauth/token', params: {
          grant_type: 'password',
          email: user.email,
          password: 'Password123-',
          client_id: application.uid,
          client_secret: application.secret
        }
        assert_response :success
        assert_equal user.id, Doorkeeper::AccessToken.find_by!(token: response.parsed_body.fetch('access_token')).resource_owner_id
      end
    end
  end

  test 'returns 429 after the global IP limit' do
    app = Rack::Attack.new(->(_env) { [200, {}, ['OK']] })
    client = Rack::MockRequest.new(app)

    travel_to Time.utc(2025, 1, 1, 0, 1) do
      3_000.times do
        assert_equal 200, client.get('/rate-limit-test', 'REMOTE_ADDR' => '192.0.2.1').status
      end
      response = client.get('/rate-limit-test', 'REMOTE_ADDR' => '192.0.2.1')
      assert_equal 429, response.status
      assert_equal '240', response['Retry-After']
    end
  end

  test 'uses the matched throttle period for the retry time' do
    travel_to Time.utc(2025, 1, 1, 0, 1) do
      3.times { post '/users/password-forgotten' }

      post '/users/password-forgotten'
      assert_response :too_many_requests
      assert_equal '3540', response.headers['Retry-After']
      assert_equal({ 'error' => 'Rate limit exceeded. Try again in 3540 seconds.' }, response.parsed_body)
    end
  end
end
