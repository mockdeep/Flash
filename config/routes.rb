# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "welcome#index"

  resource :account, only: [:new, :create, :show, :update, :destroy]
  resources :decks, only: [:new, :create, :index, :show] do
    resource :study, only: [:show, :update]
  end
  resource :session, only: [:new, :create, :destroy]

  # Subscription management
  resource :subscription, only: [:show, :new] do
    collection do
      get "/create", to: "subscriptions#create"
    end
    member do
      post :cancel
    end
  end

  # Polar.sh webhook endpoint
  post "/webhooks/polar", to: "polar_webhooks#create"
end
