Rails.application.routes.draw do
  # define single /results route
  resources :results, only: [:index]
end
