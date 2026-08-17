# frozen_string_literal: true

# Assigns a deck to a topic (creating the topic on first use) or releases it.
# Assignment is per deck: sibling decks over the same word_list move
# independently.
class TopicAssignmentsController < ApplicationController
  def create
    name = topic_params[:name].squish
    if name.blank?
      flash[:error] = t(".blank")
    else
      assign_topic(name)
      flash[:success] = t(".success", name:)
    end
    redirect_to(deck_path(deck))
  end

  def destroy
    deck.update!(topic: nil)
    flash[:success] = t(".success")
    redirect_to(deck_path(deck))
  end

  private

  def assign_topic(name)
    topic = current_user.topics.find_or_create_by!(name:)
    deck.update!(topic:)
  end

  def deck
    @deck ||= current_user.decks.find(params.expect(:deck_id))
  end

  def topic_params
    params.expect(topic: [:name])
  end
end
