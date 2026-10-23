# frozen_string_literal: true

# A source listed in the catalog: its preview, and adding or trying it,
# which starts at its first section.
class CatalogSourcesController < ApplicationController
  include DemoSession

  skip_before_action(:authenticate_user, only: [:show, :try])

  def show
    render(Views::Catalog::Show.new(deck: source.preview_deck, source:))
  end

  def copy
    current_user.deck_starting(source)
    flash[:success] = t("catalog.copy.success")
    redirect_to(decks_path)
  end

  def try
    result = Demo::CreateGuestUser.call(source:, time_zone: params[:time_zone])
    save_demo_session(result)
    redirect_to(deck_study_path(result.deck))
  end

  private

  def source
    @source ||= Source.listed.find(params.expect(:id))
  end
end
