# frozen_string_literal: true

# Lists an admin's source in the catalog, or takes it out.
class SourceListingsController < ApplicationController
  before_action(:require_admin)

  def create
    source.create_listing! unless source.listed?
    flash[:success] = t(".success")
    redirect_to(source_path(source))
  end

  def destroy
    source.listing&.destroy!
    flash[:success] = t(".success")
    redirect_to(source_path(source))
  end

  private

  def source
    @source ||= current_user.sources.find(params.expect(:source_id))
  end
end
