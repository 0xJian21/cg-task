class ReportsController < ApplicationController
  def index
    @total_clicks = Visit.count
    @top_links = ShortUrl
      .joins(:visits)
      .select("short_urls.*, COUNT(visits.id) AS click_count")
      .group("short_urls.id")
      .order("click_count DESC")
      .limit(10)
    @top_countries = Visit
      .where.not(country: nil)
      .group(:country)
      .order("count_all DESC")
      .limit(10)
      .count
  end
end
