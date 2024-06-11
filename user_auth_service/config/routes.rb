Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: {  registrations: 'registrations' }
  post 'login', to: 'sessions#create'
  get 'api/v1/users/fetch_user', to: 'users#fetch_user'
  get 'auth/validate_token', to: 'authentication#validate_token'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
