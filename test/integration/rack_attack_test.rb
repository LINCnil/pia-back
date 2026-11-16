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
      5.times do
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
