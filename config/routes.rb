# frozen_string_literal: true

Rails.application.routes.draw do
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest, defaults: { format: :json }
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root to: "welcome#index"

  resource :account, only: [:new, :create, :show, :update, :destroy]
  resources :catalog, only: [:index, :show] do
    post :copy, on: :member
    post :try, on: :member
  end
  get "demo", to: redirect("/catalog")
  resources :decks, only: [:new, :create, :index, :show, :destroy] do
    resources :lookups, only: [:create]
    resource :milestone, only: [:update]
    resource :catalog_listing, only: [:create, :destroy], controller: "catalog_listings"
    resource :replacement, only: [:new, :create], controller: "replacements"
    resource :script, only: [:update], controller: "deck_scripts"
    resource :share, only: [:create, :destroy], controller: "shares"
    resource :study, only: [:show, :update]
    resources :cards, only: [:update, :destroy]
  end

  get "shared/:token", to: "shares#show", as: :shared_deck
  post "shared/:token/copy", to: "shares#copy", as: :copy_shared_deck
  post "shared/:token/try", to: "shares#try", as: :try_shared_deck
  resource :session, only: [:new, :create, :destroy]
  resource :study_goal_reset, only: [:create]
  resource :subscription, only: [:show, :create, :destroy]
  resources :sources, only: [:index, :show, :new, :create] do
    resource :deck, only: [:create], controller: "source_decks"
    resources :snippets, only: [:new, :create]
    resources :readers, only: [:index, :create, :destroy], controller: "source_readers"
  end

  get "guide", to: "pages#guide"
  get "pricing", to: "pages#pricing"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"

  post "webhooks/creem", to: "webhooks/creem#create"

  constraints AdminConstraint.new do
    mount MissionControl::Jobs::Engine, at: "jobs"
  end
end
