# frozen_string_literal: true

Rails.application.routes.draw do
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root to: "welcome#index"

  resource :account, only: [:new, :create, :show, :update, :destroy]
  resources :catalog, only: [:index, :show] do
    post :copy, on: :member
  end
  resource :demo, only: [:show, :create], controller: "demo"
  resources :decks, only: [:new, :create, :index, :show] do
    resource :milestone, only: [:update]
    resource :study, only: [:show, :update]
    resources :cards, only: [:update]
  end
  resource :session, only: [:new, :create, :destroy]
  resource :subscription, only: [:show, :create, :destroy]

  get "pricing", to: "pages#pricing"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"

  post "webhooks/creem", to: "webhooks/creem#create"
end
