Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resource :session, only: :create
    resources :users, only: :update
    resources :events, only: [:index, :create, :show] do
      member do
        get :progress
        get :results
      end
    end
    resources :invitations, param: :token, only: [:show, :update] do
      resource :preference, only: [:show, :create, :update]
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Serve React app for all non-API routes
  get '*path', to: 'application#fallback_index_html', constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
  
  root to: 'application#fallback_index_html'
end
