require "test_helper"

class ShortUrlTest < ActiveSupport::TestCase
  # --- validations ---

  test "valid with http URL" do
    su = ShortUrl.new(target_url: "http://example.com")
    su.slug = "abc123"
    assert su.valid?
  end

  test "valid with https URL" do
    su = ShortUrl.new(target_url: "https://example.com")
    su.slug = "abc123"
    assert su.valid?
  end

  test "invalid without target_url" do
    su = ShortUrl.new(slug: "abc123")
    assert su.invalid?
    assert su.errors[:target_url].any?
  end

  test "invalid with javascript: scheme" do
    su = ShortUrl.new(target_url: "javascript:alert(1)", slug: "abc123")
    assert su.invalid?
    assert su.errors[:target_url].any?
  end

  test "invalid with file: scheme" do
    su = ShortUrl.new(target_url: "file:///etc/passwd", slug: "abc123")
    assert su.invalid?
    assert su.errors[:target_url].any?
  end

  test "invalid with data: scheme" do
    su = ShortUrl.new(target_url: "data:text/html,hi", slug: "abc123")
    assert su.invalid?
    assert su.errors[:target_url].any?
  end

  test "invalid with malformed URL" do
    su = ShortUrl.new(target_url: "not a url", slug: "abc123")
    assert su.invalid?
    assert su.errors[:target_url].any?
  end

  test "slug must be unique" do
    ShortUrl.create!(slug: "abc123", target_url: "https://example.com", title: "Ex")
    su = ShortUrl.new(slug: "abc123", target_url: "https://other.com")
    assert su.invalid?
    assert su.errors[:slug].any?
  end

  test "slug max length 15" do
    su = ShortUrl.new(slug: "a" * 16, target_url: "https://example.com")
    assert su.invalid?
    assert su.errors[:slug].any?
  end

  # --- to_param ---

  test "to_param returns the slug" do
    su = ShortUrl.new(slug: "abc123", target_url: "https://example.com")
    assert_equal "abc123", su.to_param
  end

  # --- slug generation ---

  test "generate_slug returns base62 string of default length 6" do
    slug = ShortUrl.generate_slug
    assert_match(/\A[A-Za-z0-9]{6}\z/, slug)
  end

  test "generate_slug respects custom length" do
    slug = ShortUrl.generate_slug(length: 10)
    assert_match(/\A[A-Za-z0-9]{10}\z/, slug)
  end

  test "create_with_slug! generates and saves a record" do
    su = ShortUrl.create_with_slug!(target_url: "https://example.com", title: "Ex")
    assert su.persisted?
    assert_match(/\A[A-Za-z0-9]{1,15}\z/, su.slug)
  end

  test "create_with_slug! raises on slug exhaustion" do
    # Pre-create a record with every slug that will be generated
    fixed_slug = "exhaust"
    ShortUrl.create!(slug: fixed_slug, target_url: "https://example.com")
    original = ShortUrl.method(:generate_slug)
    ShortUrl.define_singleton_method(:generate_slug) { |**| fixed_slug }
    assert_raises(ShortUrl::SlugExhaustedError) do
      ShortUrl.create_with_slug!(target_url: "https://other.com")
    end
  ensure
    ShortUrl.define_singleton_method(:generate_slug, original)
  end
end
