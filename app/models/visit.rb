class Visit < ApplicationRecord
  belongs_to :short_url
  validates :clicked_at, presence: true
end
