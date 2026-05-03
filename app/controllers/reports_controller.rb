class ReportsController < ApplicationController
  def index
    @total_clicks = Visit.count
    @all_links = ShortUrl
      .left_joins(:visits)
      .select("short_urls.*, COUNT(visits.id) AS click_count")
      .group("short_urls.id")
      .order("click_count DESC, short_urls.created_at DESC")
    @top_countries = Visit
      .where.not(country: nil)
      .group(:country)
      .order("count_all DESC")
      .limit(10)
      .count
  end
end
