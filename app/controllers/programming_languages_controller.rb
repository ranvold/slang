# frozen_string_literal: true

class ProgrammingLanguagesController < ApplicationController
  def index; end

  def search
    @programming_languages = ProgrammingLanguage.search(params[:query])
  rescue StandardError
    @programming_languages = []

    respond_to do |format|
      format.turbo_stream
    end
  end
end
