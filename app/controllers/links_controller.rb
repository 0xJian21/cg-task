class LinksController < ApplicationController
  def new
    @short_url = ShortUrl.new
  end

  def create
    target_url = params.dig(:short_url, :target_url).to_s.strip
    @short_url = ShortUrl.new(target_url: target_url)
    # Validate only the URL before generating a slug
    @short_url.validate
    @short_url.errors.delete(:slug)

    if @short_url.errors.empty?
      begin
        @short_url = ShortUrl.create_with_slug!(
          target_url: target_url,
          title: "(title unavailable)"
        )
        render :create
      rescue ShortUrl::SlugExhaustedError
        @short_url.errors.add(:base, "Could not generate a unique short URL. Please try again.")
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @short_url = ShortUrl.find(params[:id])
    @visits = @short_url.visits.order(clicked_at: :desc)
  end

  private

  def short_url_params
    params.require(:short_url).permit(:target_url)
  end
end
