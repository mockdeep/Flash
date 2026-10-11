# frozen_string_literal: true

# The users an admin has let read a snippet whatever its license.
class SnippetReadersController < ApplicationController
  before_action(:require_admin)

  def index
    reader = SnippetReader.new

    render(Views::SnippetReaders::Index.new(snippet:, reader:))
  end

  def create
    username = params.expect(reader: [:username])[:username]
    result = Snippets::Grant.call(snippet:, username:)
    return redirect_to(snippet_readers_path(snippet)) if result.success?

    render(
      Views::SnippetReaders::Index.new(snippet:, reader: result.record),
      status: :unprocessable_content,
    )
  end

  # Their deck stays, and their progress on it.
  def destroy
    snippet.readers.find(params.expect(:id)).destroy!

    redirect_to(snippet_readers_path(snippet))
  end

  private

  def snippet
    @snippet ||= current_user.snippets.find(params.expect(:snippet_id))
  end
end
