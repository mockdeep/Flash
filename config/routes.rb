# frozen_string_literal: true

Rails.application.routes.draw do
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest, defaults: { format: :json }
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root to: "welcome#index"

  resource :account, only: [:new, :create, :show, :update, :destroy]
  resources :catalog, only: [:index, :show] do
    post :copy, on: :member
  end
  resource :demo, only: [:show, :create], controller: "demo"
  resources :decks, only: [:new, :create, :index, :show, :destroy] do
    resource :milestone, only: [:update]
    resource :catalog_listing, only: [:create, :destroy], controller: "catalog_listings"
    resource :replacement, only: [:new, :create], controller: "replacements"
    resource :share, only: [:create, :destroy], controller: "shares"
    resource :study, only: [:show, :update]
    resource :topic_assignment, only: [:create, :destroy], controller: "topic_assignments"
    resources :cards, only: [:update, :destroy]
  end

  get "shared/:token", to: "shares#show", as: :shared_deck
  post "shared/:token/copy", to: "shares#copy", as: :copy_shared_deck
  post "shared/:token/try", to: "shares#try", as: :try_shared_deck
  resource :session, only: [:new, :create, :destroy]
  resource :subscription, only: [:show, :create, :destroy]

  get "pricing", to: "pages#pricing"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"

  post "webhooks/creem", to: "webhooks/creem#create"
end
