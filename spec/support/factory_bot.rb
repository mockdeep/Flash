# frozen_string_literal: true

require "factory_bot_rails"

module FactoryCache
  extend self

  def user
    return FactoryBot.create(:user) if @disabled
    return @user if @user&.persisted?

    @user = FactoryBot.create(:user)
  end

  def deck
    return FactoryBot.create(:deck) if @disabled
    return @deck if @deck&.persisted?

    @deck = FactoryBot.create(:deck)
  end

  def music_deck
    return FactoryBot.create(:music_deck) if @disabled
    return @music_deck if @music_deck&.persisted?

    @music_deck = FactoryBot.create(:music_deck)
  end

  def disable
    @disabled = true
    yield
  ensure
    @disabled = false
  end

  def reset
    @user = nil
    @deck = nil
    @music_deck = nil
  end
end

RSpec.configure do |config|
  config.include(FactoryBot::Syntax::Methods)

  config.after do
    FactoryBot.rewind_sequences
    FactoryCache.reset
  end
end

module FactoryBot
  module Syntax
    module Methods
      def default_deck
        FactoryCache.deck
      end

      def default_music_deck
        FactoryCache.music_deck
      end

      def default_user
        FactoryCache.user
      end
    end
  end
end
