require "net/http"
require "resolv"
require "ipaddr"

class TitleFetcherService
  MAX_REDIRECTS = 5
  MAX_BODY_SIZE = 100_000
  TIMEOUT = 5
  FALLBACK = "(title unavailable)"

  BLOCKED_RANGES = [
    IPAddr.new("127.0.0.0/8"),
    IPAddr.new("::1/128"),
    IPAddr.new("10.0.0.0/8"),
    IPAddr.new("172.16.0.0/12"),
    IPAddr.new("192.168.0.0/16"),
    IPAddr.new("169.254.0.0/16")
  ].freeze

  def self.call(url)
    new(url).call
  end

  def call
    fetch_title(@url, MAX_REDIRECTS)
  rescue StandardError
    FALLBACK
  end

  private

  def initialize(url)
    @url = url
  end

  def fetch_title(url, hops_left)
    return FALLBACK if hops_left <= 0

    uri = URI.parse(url)
    return FALLBACK unless %w[http https].include?(uri.scheme)

    ssrf_check!(uri.host)

    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == "https",
                    open_timeout: TIMEOUT,
                    read_timeout: TIMEOUT) do |http|
      response = http.get(uri.request_uri)

      if response.is_a?(Net::HTTPRedirection)
        return fetch_title(response["Location"], hops_left - 1)
      end

      return FALLBACK unless response["Content-Type"]&.include?("text/html")

      body = response.body.to_s
      return FALLBACK if body.bytesize > MAX_BODY_SIZE

      parse_title(body)
    end
  end

  def ssrf_check!(hostname)
    addresses = Resolv.getaddresses(hostname)
    addresses.each do |addr|
      ip = IPAddr.new(addr)
      raise "SSRF blocked: #{addr}" if BLOCKED_RANGES.any? { |range| range.include?(ip) }
    end
  end

  def parse_title(html)
    doc = Nokogiri::HTML(html)
    title = doc.at("title")&.text&.strip
    title.presence || FALLBACK
  end
end
