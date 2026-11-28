# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::DeckFinished, type: :view do
  def render_for(deck, demo: false)
    Capybara.string(view.render(described_class.new(deck:, demo:)))
  end

  def finished_deck = create(:basic_card, :done).deck

  it "offers a guest the sign-up" do
    expect(render_for(finished_deck, demo: true)).to have_link("Sign Up Free")
  end

  it "links to the next deck with work today" do
    deck = finished_deck
    next_deck = create(:basic_card, deck: create(:deck)).deck

    expect(render_for(deck))
      .to have_link("Next Deck", href: "/decks/#{next_deck.id}/study")
  end

  it "leaves out Next Deck when no other deck has work today" do
    expect(render_for(finished_deck)).to have_no_link("Next Deck")
  end
end
