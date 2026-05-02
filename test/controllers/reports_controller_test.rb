require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "GET /reports returns 200" do
    get reports_path
    assert_response :success
  end

  test "GET /reports shows total click count" do
    su = ShortUrl.create!(slug: "aaa111", target_url: "https://a.com", title: "A")
    Visit.create!(short_url: su, ip_address: "1.1.1.1", clicked_at: 1.hour.ago)
    Visit.create!(short_url: su, ip_address: "2.2.2.2", clicked_at: 2.hours.ago)

    get reports_path
    assert_response :success
    assert_match "Total clicks: 2", response.body
  end

  test "GET /reports shows top links sorted by click count" do
    su1 = ShortUrl.create!(slug: "top111", target_url: "https://top.com", title: "Top")
    su2 = ShortUrl.create!(slug: "low222", target_url: "https://low.com", title: "Low")
    3.times { Visit.create!(short_url: su1, ip_address: "1.1.1.1", clicked_at: 1.hour.ago) }
    1.times { Visit.create!(short_url: su2, ip_address: "2.2.2.2", clicked_at: 1.hour.ago) }

    get reports_path
    assert_response :success
    assert_match "top111", response.body
    assert_match "low222", response.body
    assert(/top111.*low222/m.match?(response.body), "top link should appear before low link")
  end

  test "GET /reports shows top countries excluding nil" do
    su = ShortUrl.create!(slug: "geo123", target_url: "https://geo.com", title: "Geo")
    Visit.create!(short_url: su, ip_address: "1.1.1.1", clicked_at: 1.hour.ago, country: "US")
    Visit.create!(short_url: su, ip_address: "2.2.2.2", clicked_at: 1.hour.ago, country: "US")
    Visit.create!(short_url: su, ip_address: "3.3.3.3", clicked_at: 1.hour.ago, country: "DE")
    Visit.create!(short_url: su, ip_address: "4.4.4.4", clicked_at: 1.hour.ago, country: nil)

    get reports_path
    assert_response :success
    assert_match "US", response.body
    assert_match "DE", response.body
  end

  test "GET /reports shows empty state when no visits" do
    get reports_path
    assert_response :success
    assert_match "No visits yet", response.body
  end
end
