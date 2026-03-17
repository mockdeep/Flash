# frozen_string_literal: true

class StudiesController < ApplicationController
  skip_before_action(:authenticate_user)
  before_action(:authenticate_guest)

  def show
    deck = current_user.decks.find(params[:deck_id])
    study = Study.new(deck:)
    reset_counters
    render_study(Views::Studies::Show, deck:, study:)
  end

  def update
    deck = current_user.decks.find(params[:deck_id])
    result = Study.new(deck:).answer_card(**answer_params)
    increment_counters(result)
    render_study(Views::Studies::Update, deck:, result:)
  end

  private

  def reset_counters
    reset_daily_counters
    return unless params[:reset_session] || milestone_reached?

    session[:study_completed] = 0
  end

  def milestone_reached?
    (session[:study_completed] || 0) >= 50
  end

  def increment_counters(result)
    reset_daily_counters
    session[:study_completed] += 1 if result.card_completed?
  end

  def render_study(view, **args)
    render(
      view.new(
        **args,
        completed: session[:study_completed],
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
    params.expect(answer: [:card_id, :answer, { possible_answers: [] }])
      .to_h.symbolize_keys
  end
end
