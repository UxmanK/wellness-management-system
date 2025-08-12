Rails.application.routes.draw do
  # Health check for Render
  get "healthz" => "api/v1/health#check"
  
  namespace :api do
    namespace :v1 do
      resources :clients, only: [:index, :show, :create, :update, :destroy]
      resources :appointments, only: [:index, :show, :create, :update, :destroy] do
        member do
          patch :cancel
        end
      end
      
      # Sync routes
      namespace :sync do
        get :status
        post :clients
        post :appointments
        post :all
        post :force
      end
    end
  end

  require 'sidekiq/web'

  # Add session middleware for Sidekiq Web
  Sidekiq::Web.use ActionDispatch::Cookies
  Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: '_your_app_session'
  
  mount Sidekiq::Web => '/sidekiq'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#check", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
