# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "welcome#index"

  resource :account, only: [:new, :create, :show, :update, :destroy]
  resources :decks, only: [:new, :create, :index, :show] do
    resource :study, only: [:show, :update]
  end
  resource :session, only: [:new, :create, :destroy]
  resource :subscription, only: [:show, :create, :destroy]

  post "webhooks/creem", to: "webhooks/creem#create"
end
