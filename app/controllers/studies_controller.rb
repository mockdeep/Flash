# frozen_string_literal: true

class StudiesController < ApplicationController
  def show
    deck = current_user.decks.find(params[:deck_id])
    study = Study.new(deck:)

    render(Views::Studies::Show.new(deck:, study:))
  end

  def update
    deck = current_user.decks.find(params[:deck_id])
    study = Study.new(deck:)

    result = study.answer_card(**answer_params)

    render(Views::Studies::Update.new(deck:, result:))
  end

  private

  def answer_params
    params.expect(answer: [:card_id, :answer, { possible_answers: [] }])
      .to_h.symbolize_keys
  end
end
