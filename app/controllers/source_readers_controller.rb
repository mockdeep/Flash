# frozen_string_literal: true

# The users an admin has let read a source whatever its license.
class SourceReadersController < ApplicationController
  before_action(:require_admin)

  def index
    reader = SourceReader.new

    render(Views::SourceReaders::Index.new(source:, reader:))
  end

  def create
    username = params.expect(reader: [:username])[:username]
    result = Sources::Grant.call(source:, username:)
    return redirect_to(source_readers_path(source)) if result.success?

    render(
      Views::SourceReaders::Index.new(source:, reader: result.record),
      status: :unprocessable_content,
    )
  end

  # Their deck stays, and their progress on it.
  def destroy
    source.readers.find(params.expect(:id)).destroy!

    redirect_to(source_readers_path(source))
  end

  private

  def source
    @source ||= current_user.sources.find(params.expect(:source_id))
  end
end
