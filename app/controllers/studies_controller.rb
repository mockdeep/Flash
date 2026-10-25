# frozen_string_literal: true

class StudiesController < ApplicationController
  skip_before_action(:authenticate_user)
  before_action(:authenticate_guest)

  def show
    deck = find_deck
    deck.catch_up_round!
    practice = practice?(deck)
    study = Study.for(deck:, exclude_card_id: params[:exclude], practice:)
    deck.study_days.today.keep_going! if params[:reset_session]
    render_study(show_view_class(deck), deck:, study:)
  end

  def update
    deck = find_deck
    practice = practice?(deck)
    result = Study.for(deck:, practice:).record_answer(params)
    deck.update!(last_studied_at: Time.current)
    record_completion(deck, result)
    if result.reading_passed?
      render_translation_stage(deck, result.card, practice:)
    else
      render_study(update_view_class(deck), deck:, result:)
    end
  end

  private

  def find_deck = current_user.decks.find(params.expect(:deck_id))

  # Practice is only for a deck whose cards left have all had their turn
  # today; past midnight, a practice link studies as usual.
  def practice?(deck)
    params[:practice].present? && deck.waiting_for_tomorrow?
  end

  # A passed reading stage re-renders the question view pinned to the same
  # card, now asking for the translation.
  def render_translation_stage(deck, card, practice:)
    study = Study.for(deck:, card_id: card.id, practice:)
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

  # Music decks have no study goal, so their views take no session progress.
  def render_study(view, deck:, **args)
    args.merge!(session_progress(deck)) unless deck.music?
    render(view.new(**args, deck:, demo: current_user.guest?))
  end

  def session_progress(deck)
    study_day = deck.study_days.today
    { completed: study_day.completed_count, study_goal: study_day.study_goal }
  end
end
