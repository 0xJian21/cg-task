require "test_helper"

class GeolocateServiceTest < ActiveSupport::TestCase
  def fake_result(found:, country: nil, city: nil)
    result = Object.new
    result.define_singleton_method(:found?) { found }
    if found
      country_obj = Object.new
      country_obj.define_singleton_method(:name) { country }
      result.define_singleton_method(:country) { country_obj }
      city_obj = Object.new
      city_obj.define_singleton_method(:name) { city }
      result.define_singleton_method(:city) { city_obj }
    end
    result
  end

  def stub_maxmind(result, &block)
    db = Object.new
    db.define_singleton_method(:lookup) { |_ip| result }
    stub_method(MaxMindDB, :new, ->(_path) { db }, &block)
  end

  test "returns country and city for a known IP" do
    result = fake_result(found: true, country: "United States", city: "New York")
    stub_maxmind(result) do
      assert_equal({ country: "United States", city: "New York" }, GeolocateService.call("8.8.8.8"))
    end
  end

  test "returns nil hash when IP is not found in database" do
    result = fake_result(found: false)
    stub_maxmind(result) do
      assert_equal({ country: nil, city: nil }, GeolocateService.call("8.8.8.8"))
    end
  end

  test "returns nil hash when mmdb file is missing" do
    stub_method(MaxMindDB, :new, ->(_path) { raise Errno::ENOENT, "no file" }) do
      assert_equal({ country: nil, city: nil }, GeolocateService.call("8.8.8.8"))
    end
  end

  test "returns nil hash for a bad IP address" do
    db = Object.new
    db.define_singleton_method(:lookup) { |_ip| raise ArgumentError, "invalid IP" }
    stub_method(MaxMindDB, :new, ->(_path) { db }) do
      assert_equal({ country: nil, city: nil }, GeolocateService.call("not-an-ip"))
    end
  end
end
