# frozen_string_literal: true

# Assigns a deck's data_set to a topic (creating the topic on first use) or
# releases it. Topics group data_sets, so sibling decks move together.
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
    deck.data_set.update!(topic: nil)
    flash[:success] = t(".success")
    redirect_to(deck_path(deck))
  end

  private

  def assign_topic(name)
    topic = current_user.topics.find_or_create_by!(name:)
    deck.data_set.update!(topic:)
  end

  def deck
    @deck ||= current_user.decks.find(params.expect(:deck_id))
  end

  def topic_params
    params.expect(topic: [:name])
  end
end
