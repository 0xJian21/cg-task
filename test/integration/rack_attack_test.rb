require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.reset!
  end

  teardown do
    Rack::Attack.enabled = false
    Rack::Attack.cache.store = Rails.cache
    Rack::Attack.reset!
  end

  test "POST /links returns 429 after 10 requests from same IP within one minute" do
    stub_method(TitleFetcherService, :call, ->(_url) { "Test" }) do
      10.times do |i|
        post links_path,
          params: { short_url: { target_url: "https://example.com/#{i}" } },
          headers: { "REMOTE_ADDR" => "1.2.3.4" }
        assert_response :redirect
      end

      post links_path,
        params: { short_url: { target_url: "https://example.com/11" } },
        headers: { "REMOTE_ADDR" => "1.2.3.4" }
      assert_response :too_many_requests
    end
  end

  test "POST /links from different IP is not throttled" do
    stub_method(TitleFetcherService, :call, ->(_url) { "Test" }) do
      10.times do |i|
        post links_path,
          params: { short_url: { target_url: "https://example.com/#{i}" } },
          headers: { "REMOTE_ADDR" => "1.2.3.4" }
      end

      post links_path,
        params: { short_url: { target_url: "https://example.com/other" } },
        headers: { "REMOTE_ADDR" => "9.9.9.9" }
      assert_response :redirect
    end
  end
end
