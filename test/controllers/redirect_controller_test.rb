require "test_helper"

class RedirectControllerTest < ActionDispatch::IntegrationTest
  test "GET /:slug with known slug redirects 302 to target_url" do
    su = ShortUrl.create!(slug: "abc123", target_url: "https://example.com", title: "Ex")
    get "/#{su.slug}"
    assert_redirected_to "https://example.com"
  end

  test "GET /:slug with unknown slug returns 404" do
    get "/zzz999"
    assert_response :not_found
  end
end
