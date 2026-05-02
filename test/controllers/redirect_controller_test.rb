require "test_helper"

class RedirectControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_geo_call = GeolocateService.method(:call)
    GeolocateService.define_singleton_method(:call) { |_ip| { country: nil, city: nil } }
  end

  teardown do
    GeolocateService.define_singleton_method(:call, &@original_geo_call)
  end

  test "GET /:slug with known slug redirects 302 to target_url" do
    su = ShortUrl.create!(slug: "abc123", target_url: "https://example.com", title: "Ex")
    get "/#{su.slug}"
    assert_redirected_to "https://example.com"
  end

  test "GET /:slug with unknown slug returns 404" do
    get "/zzz999"
    assert_response :not_found
  end

  test "GET /:slug creates one Visit with correct short_url_id and non-null clicked_at" do
    su = ShortUrl.create!(slug: "abc123", target_url: "https://example.com", title: "Ex")
    assert_difference "Visit.count", 1 do
      get "/#{su.slug}"
    end
    visit = Visit.last
    assert_equal su.id, visit.short_url_id
    assert_not_nil visit.clicked_at
  end

  test "GET /:slug with unknown slug does not create a Visit" do
    assert_no_difference "Visit.count" do
      get "/zzz999"
    end
  end

  test "GET /:slug stores geo country and city on the visit" do
    su = ShortUrl.create!(slug: "abc123", target_url: "https://example.com", title: "Ex")
    stub_method(GeolocateService, :call, ->(_ip) { { country: "Germany", city: "Berlin" } }) do
      get "/#{su.slug}"
    end
    visit = Visit.last
    assert_equal "Germany", visit.country
    assert_equal "Berlin", visit.city
  end

  test "GET /:slug still redirects when geo lookup returns nils" do
    su = ShortUrl.create!(slug: "abc123", target_url: "https://example.com", title: "Ex")
    get "/#{su.slug}"
    assert_redirected_to "https://example.com"
    visit = Visit.last
    assert_nil visit.country
    assert_nil visit.city
  end
end
