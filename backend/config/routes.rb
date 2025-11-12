Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show"

  namespace :api do
    resource :session, only: :create
    resources :users, only: :update
    resources :events, only: [:index, :create, :show] do
      member do
        get :progress
        get :results
      end
      resource :votes, only: :create, controller: "event_votes"
    end
    resources :invitations, param: :token, only: [:index, :show, :update] do
      resource :preference, only: [:show, :create, :update]
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Serve React app for all non-API routes
  root "pages#home"
  get "*path", to: "pages#home", constraints: ->(req) { !req.xhr? && req.format.html? }

end