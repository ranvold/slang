# frozen_string_literal: true

class ProgrammingLanguagesController < ApplicationController
  def index; end

  def search
    result = ProgrammingLanguage::Operation::Search.call(raw_query: params[:query])

    @programming_languages = ProgrammingLanguage.search(result[:prepared_query])
  rescue StandardError
    @programming_languages = []

    respond_to do |format|
      format.turbo_stream
    end
  end
end
