Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "links#new"
  resources :links, only: %i[new create show]
  get "/reports" => "reports#index", as: :reports

  # slug route last so it cannot shadow named routes
  get "/:slug" => "redirect#show", as: :short_url_redirect
end
