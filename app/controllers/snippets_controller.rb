# frozen_string_literal: true

class SnippetsController < ApplicationController
  before_action(:require_admin)

  def new
    render(Views::Snippets::New.new(snippet: source.snippets.build))
  end

  def create
    result = Snippets::Create.call(source:, **snippet_params)
    return redirect_to(source_path(source)) if result.success?

    render(
      Views::Snippets::New.new(snippet: result.record),
      status: :unprocessable_content,
    )
  end

  private

  def source
    @source ||= current_user.sources.find(params.expect(:source_id))
  end

  def snippet_params
    params.expect(snippet: [:heading, :body]).to_h.symbolize_keys
  end
end
