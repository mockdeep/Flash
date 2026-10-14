# frozen_string_literal: true

class SourcesController < ApplicationController
  before_action(:require_admin)

  def index
    sources = current_user.sources.order(id: :desc)

    render(Views::Sources::Index.new(sources:))
  end

  def show
    source = current_user.sources.find(params.expect(:id))

    render(Views::Sources::Show.new(source:))
  end

  def new
    render(Views::Sources::New.new(source: Source.new))
  end

  def create
    result = Sources::Create.call(user: current_user, **source_params)
    return redirect_to(source_path(result.record)) if result.success?

    render(
      Views::Sources::New.new(source: result.record),
      status: :unprocessable_content,
    )
  end

  private

  def source_params
    params.expect(source: [:title, :language, :author, :source_url, :license])
      .to_h.symbolize_keys
  end
end
