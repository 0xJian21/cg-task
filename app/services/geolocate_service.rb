class GeolocateService
  MMDB_PATH = Rails.root.join("GeoLite2-City.mmdb").to_s

  def self.call(ip)
    new(ip).call
  end

  def call
    db = MaxMindDB.new(MMDB_PATH)
    result = db.lookup(@ip)
    return { country: nil, city: nil } unless result.found?

    { country: result.country.name, city: result.city.name }
  rescue StandardError
    { country: nil, city: nil }
  end

  private

  def initialize(ip)
    @ip = ip
  end
end
