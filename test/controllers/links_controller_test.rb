require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  test "GET / returns 200 and renders shorten form" do
    get root_path
    assert_response :success
    assert_select "form"
  end

  test "GET /links/new returns 200" do
    get new_link_path
    assert_response :success
  end

  test "POST /links with valid URL creates record and redirects to stats page" do
    stub_method(TitleFetcherService, :call, ->(_url) { "Example Domain" }) do
      assert_difference "ShortUrl.count", 1 do
        post links_path, params: { short_url: { target_url: "https://example.com" } }
      end
      su = ShortUrl.last
      assert_equal "https://example.com", su.target_url
      assert_match(/[A-Za-z0-9]{6}/, su.slug)
      assert_equal "Example Domain", su.title
      assert_redirected_to link_path(su)
    end
  end

  test "POST /links stores fallback title when fetcher fails" do
    stub_method(TitleFetcherService, :call, ->(_url) { "(title unavailable)" }) do
      assert_difference "ShortUrl.count", 1 do
        post links_path, params: { short_url: { target_url: "https://example.com" } }
      end
      su = ShortUrl.last
      assert_equal "(title unavailable)", su.title
      assert_redirected_to link_path(su)
    end
  end

  test "POST /links with blank URL returns 422 and no record" do
    assert_no_difference "ShortUrl.count" do
      post links_path, params: { short_url: { target_url: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "POST /links with invalid URL returns 422 and no record" do
    assert_no_difference "ShortUrl.count" do
      post links_path, params: { short_url: { target_url: "not a url" } }
    end
    assert_response :unprocessable_entity
  end

  test "POST /links with javascript: scheme returns 422 and no record" do
    assert_no_difference "ShortUrl.count" do
      post links_path, params: { short_url: { target_url: "javascript:alert(1)" } }
    end
    assert_response :unprocessable_entity
  end

  test "GET /links/:slug shows stats page with click count" do
    su = ShortUrl.create!(slug: "testslg", target_url: "https://example.com", title: "Ex")
    Visit.create!(short_url: su, ip_address: "1.2.3.4", clicked_at: 2.hours.ago)
    Visit.create!(short_url: su, ip_address: "5.6.7.8", clicked_at: 1.hour.ago)
    get link_path(su)
    assert_equal "/links/testslg", link_path(su)
    assert_response :success
    assert_match "Total clicks: 2", response.body
    assert_match "1.2.3.4", response.body
    assert_match "5.6.7.8", response.body
  end

  test "GET /links/:slug shows empty state when no visits" do
    su = ShortUrl.create!(slug: "abc123", target_url: "https://example.com", title: "Ex")
    get link_path(su)
    assert_response :success
    assert_match "No visits yet", response.body
  end

  test "GET /links/1 returns 404 when no slug named 1" do
    get "/links/1"
    assert_response :not_found
  end

  test "POST /links with invalid URL renders inline error, no top-level error_explanation block" do
    post links_path, params: { short_url: { target_url: "javascript:alert(1)" } }
    assert_response :unprocessable_entity
    assert_select "#error_explanation", count: 0
    assert_select ".field-error"
  end

  test "POST /links with invalid URL form has label associated with target_url field" do
    post links_path, params: { short_url: { target_url: "" } }
    assert_response :unprocessable_entity
    assert_select "label[for='short_url_target_url']"
  end
end
