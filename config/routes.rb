# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "welcome#index"

  resource :account, only: [:new, :create, :show, :update, :destroy]
  resources :decks, only: [:new, :create, :index]
  resource :session, only: [:new, :create, :destroy]
end
