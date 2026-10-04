# frozen_string_literal: true

class SnippetsController < ApplicationController
  before_action(:require_admin)

  def index
    snippets = current_user.snippets.order(created_at: :desc)

    render(Views::Snippets::Index.new(snippets:))
  end

  def new
    render(Views::Snippets::New.new(snippet: Snippet.new, list_names:))
  end

  def create
    result = Snippets::Create.call(user: current_user, **snippet_params)
    return redirect_to(snippets_path) if result.success?

    render(
      Views::Snippets::New.new(snippet: result.record, list_names:),
      status: :unprocessable_content,
    )
  end

  private

  def list_names = current_user.word_lists.order(:name).pluck(:name)

  def snippet_params
    params.expect(snippet: [:list_name, :title, :author, :body])
      .to_h.symbolize_keys
  end
end
