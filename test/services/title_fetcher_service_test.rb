require "test_helper"

class TitleFetcherServiceTest < ActiveSupport::TestCase
  FakeOkResponse = Struct.new(:content_type, :body, keyword_init: true) do
    def [](key) = key.downcase == "content-type" ? content_type : nil
    def is_a?(klass) = klass == Net::HTTPSuccess || super
  end

  FakeRedirectResponse = Struct.new(:location, keyword_init: true) do
    def [](key) = key.downcase == "location" ? location : nil
    def is_a?(klass) = klass == Net::HTTPRedirection || super
  end

  def html_response(title_text)
    FakeOkResponse.new(
      content_type: "text/html; charset=utf-8",
      body: "<html><head><title>#{title_text}</title></head></html>"
    )
  end

  def stub_http_start(response, &block)
    http = Object.new
    http.define_singleton_method(:get) { |_path| response }
    stub_method(Net::HTTP, :start, ->(*_args, **_opts, &blk) { blk.call(http) }, &block)
  end

  def with_public_ip(&block)
    stub_method(Resolv, :getaddresses, ->(_host) { [ "93.184.216.34" ] }, &block)
  end

  test "returns title from HTML page" do
    with_public_ip do
      stub_http_start(html_response("Hello World")) do
        assert_equal "Hello World", TitleFetcherService.call("https://example.com")
      end
    end
  end

  test "returns fallback on open timeout" do
    with_public_ip do
      stub_method(Net::HTTP, :start, ->(*_args, **_opts, &_blk) { raise Net::OpenTimeout }) do
        assert_equal "(title unavailable)", TitleFetcherService.call("https://example.com")
      end
    end
  end

  test "returns fallback on read timeout" do
    with_public_ip do
      stub_method(Net::HTTP, :start, ->(*_args, **_opts, &_blk) { raise Net::ReadTimeout }) do
        assert_equal "(title unavailable)", TitleFetcherService.call("https://example.com")
      end
    end
  end

  test "returns fallback for non-HTML content type" do
    response = FakeOkResponse.new(content_type: "application/octet-stream", body: "binary")
    with_public_ip do
      stub_http_start(response) do
        assert_equal "(title unavailable)", TitleFetcherService.call("https://example.com/file.bin")
      end
    end
  end

  test "returns fallback when title tag is missing" do
    response = FakeOkResponse.new(content_type: "text/html", body: "<html><body>no title</body></html>")
    with_public_ip do
      stub_http_start(response) do
        assert_equal "(title unavailable)", TitleFetcherService.call("https://example.com")
      end
    end
  end

  test "returns fallback for loopback IP (SSRF block)" do
    stub_method(Resolv, :getaddresses, ->(_host) { [ "127.0.0.1" ] }) do
      assert_equal "(title unavailable)", TitleFetcherService.call("http://localhost/secret")
    end
  end

  test "returns fallback for RFC1918 10.x IP (SSRF block)" do
    stub_method(Resolv, :getaddresses, ->(_host) { [ "10.0.0.1" ] }) do
      assert_equal "(title unavailable)", TitleFetcherService.call("http://internal.corp/secret")
    end
  end

  test "returns fallback for RFC1918 192.168.x IP (SSRF block)" do
    stub_method(Resolv, :getaddresses, ->(_host) { [ "192.168.1.1" ] }) do
      assert_equal "(title unavailable)", TitleFetcherService.call("http://internal.corp/secret")
    end
  end

  test "returns fallback for link-local IP (SSRF block)" do
    stub_method(Resolv, :getaddresses, ->(_host) { [ "169.254.169.254" ] }) do
      assert_equal "(title unavailable)", TitleFetcherService.call("http://metadata.google.internal/")
    end
  end

  test "returns fallback when redirect hops exhausted" do
    redirect = FakeRedirectResponse.new(location: "http://example.com/loop")
    http = Object.new
    http.define_singleton_method(:get) { |_path| redirect }
    with_public_ip do
      stub_method(Net::HTTP, :start, ->(*_args, **_opts, &blk) { blk.call(http) }) do
        assert_equal "(title unavailable)", TitleFetcherService.call("http://example.com/loop")
      end
    end
  end

  test "returns fallback for oversized response body" do
    response = FakeOkResponse.new(content_type: "text/html", body: "x" * 200_000)
    with_public_ip do
      stub_http_start(response) do
        assert_equal "(title unavailable)", TitleFetcherService.call("https://example.com")
      end
    end
  end
end
