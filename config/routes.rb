# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "welcome#index"

  resource :account, only: [:new, :create, :show, :update, :destroy]
  resources :catalog, only: [:index, :show] do
    post :copy, on: :member
  end
  resources :decks, only: [:new, :create, :index, :show] do
    resource :study, only: [:show, :update]
  end
  resource :session, only: [:new, :create, :destroy]
  resource :subscription, only: [:show, :create, :destroy]

  get "pricing", to: "pages#pricing"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"

  post "webhooks/creem", to: "webhooks/creem#create"
end
