require "test_helper"

class VisitTest < ActiveSupport::TestCase
  def setup
    @short_url = ShortUrl.create!(slug: "abc123", target_url: "https://example.com", title: "Ex")
  end

  test "valid visit requires short_url and clicked_at" do
    v = Visit.new(short_url: @short_url, ip_address: "1.2.3.4", clicked_at: Time.current)
    assert v.valid?
  end

  test "invalid without short_url" do
    v = Visit.new(clicked_at: Time.current)
    assert_not v.valid?
    assert v.errors[:short_url].any?
  end

  test "invalid without clicked_at" do
    v = Visit.new(short_url: @short_url)
    assert_not v.valid?
    assert v.errors[:clicked_at].any?
  end

  test "short_url has many visits" do
    Visit.create!(short_url: @short_url, ip_address: "1.2.3.4", clicked_at: Time.current)
    Visit.create!(short_url: @short_url, ip_address: "5.6.7.8", clicked_at: Time.current)
    assert_equal 2, @short_url.visits.count
  end
end
