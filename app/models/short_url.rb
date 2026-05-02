class ShortUrl < ApplicationRecord
  class SlugExhaustedError < StandardError; end

  has_many :visits, dependent: :destroy

  MAX_SLUG_LENGTH = 15
  DEFAULT_SLUG_LENGTH = 6
  MAX_RETRIES = 5
  ALLOWED_SCHEMES = %w[http https].freeze

  validates :target_url, presence: true
  validates :slug, presence: true, uniqueness: true, length: { maximum: MAX_SLUG_LENGTH }
  validate :target_url_scheme

  def self.generate_slug(length: DEFAULT_SLUG_LENGTH)
    SecureRandom.alphanumeric(length)
  end

  def self.create_with_slug!(attributes = {})
    MAX_RETRIES.times do
      slug = generate_slug
      record = new(attributes.merge(slug: slug))
      return record.tap(&:save!) unless ShortUrl.exists?(slug: slug)
    rescue ActiveRecord::RecordInvalid => e
      raise unless e.record.errors[:slug].any?
    end
    raise SlugExhaustedError, "Could not generate a unique slug after #{MAX_RETRIES} attempts"
  end

  private

  def target_url_scheme
    return if target_url.blank?

    uri = URI.parse(target_url)
    unless ALLOWED_SCHEMES.include?(uri.scheme)
      errors.add(:target_url, "must use http or https scheme")
    end
  rescue URI::InvalidURIError
    errors.add(:target_url, "is not a valid URL")
  end
end
