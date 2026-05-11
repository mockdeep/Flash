# frozen_string_literal: true

class StudiesController < ApplicationController
  skip_before_action(:authenticate_user)
  before_action(:authenticate_guest)

  def show
    deck = current_user.decks.find(params.expect(:deck_id))
    study = Study.for(deck:)
    reset_counters
    render_study(show_view_class(deck), deck:, study:)
  end

  def update
    deck = current_user.decks.find(params.expect(:deck_id))
    result = Study.for(deck:).answer_card(**answer_params)
    increment_counters(result)
    render_study(update_view_class(deck), deck:, result:)
  end

  private

  def show_view_class(deck)
    deck.music? ? Views::Studies::MusicShow : Views::Studies::Show
  end

  def update_view_class(deck)
    deck.music? ? Views::Studies::MusicUpdate : Views::Studies::Update
  end

  def reset_counters
    reset_daily_counters
    return unless params[:reset_session]

    session[:study_completed] = 0
  end

  def increment_counters(result)
    reset_daily_counters
    session[:study_completed] += 1 if result.card_completed?
  end

  def render_study(view, deck:, **args)
    render(
      view.new(
        **args,
        deck:,
        completed: session[:study_completed],
        study_goal: deck.study_goal,
        demo: current_user.guest?,
      ),
    )
  end

  def reset_daily_counters
    return if session[:study_date] == Date.current.to_s

    session[:study_date] = Date.current.to_s
    session[:study_completed] = 0
  end

  def answer_params
    params.expect(
      answer: [
        :card_id,
        :answer,
        { possible_answers: [], wrong_answers: [] },
      ],
    ).to_h.symbolize_keys
  end
end
