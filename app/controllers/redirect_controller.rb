class RedirectController < ApplicationController
  def show
    short_url = ShortUrl.find_by(slug: params[:slug])
    if short_url
      short_url.visits.create!(
        ip_address: request.remote_ip,
        clicked_at: Time.current
      )
      redirect_to short_url.target_url, allow_other_host: true, status: :found
    else
      render plain: "Not Found", status: :not_found
    end
  end
end
