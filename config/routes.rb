Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "notifications#index"

  namespace :api do
    resources :mobile_devices
    resources :notifications
  end

  resources :sessions, only: [ :create, :destroy ]
  resources :notifications, only: [ :create ] do
    get "search_mobile_devices", on: :collection
  end
  resources :mobile_devices, only: [ :new, :show, :create ] do
    get "stats", on: :collection
  end
  resources :mobile_users, only: [] do
    delete "remove_topic", on: :member
    post "add_topic", on: :member
  end
  resources :mobile_accesses, except: [ :show, :destroy ]
end
