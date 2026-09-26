# frozen_string_literal: true

class StudiesController < ApplicationController
  skip_before_action(:authenticate_user)
  before_action(:authenticate_guest)

  def show
    deck = current_user.decks.find(params.expect(:deck_id))
    study = Study.for(deck:, exclude_card_id: params[:exclude])
    deck.study_days.today.start_batch! if params[:reset_session]
    render_study(show_view_class(deck), deck:, study:)
  end

  def update
    deck = current_user.decks.find(params.expect(:deck_id))
    result = Study.for(deck:).record_answer(params)
    deck.update!(last_studied_at: Time.current)
    record_completion(deck, result)
    if result.reading_passed?
      render_translation_stage(deck, result.card)
    else
      render_study(update_view_class(deck), deck:, result:)
    end
  end

  private

  # A passed reading stage re-renders the question view pinned to the same
  # card, now asking for the translation.
  def render_translation_stage(deck, card)
    study = Study.for(deck:, card_id: card.id)
    render_study(show_view_class(deck), deck:, study:)
  end

  def show_view_class(deck)
    deck.music? ? Views::Studies::MusicShow : Views::Studies::Show
  end

  def update_view_class(deck)
    deck.music? ? Views::Studies::MusicUpdate : Views::Studies::Update
  end

  def record_completion(deck, result)
    deck.study_days.today.record_completion! if result.card_completed?
  end

  def render_study(view, deck:, **args)
    render(
      view.new(
        **args,
        deck:,
        completed: deck.study_days.today.completed_count,
        study_goal: deck.study_goal,
        demo: current_user.guest?,
      ),
    )
  end
end
