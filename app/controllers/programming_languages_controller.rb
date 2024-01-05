# frozen_string_literal: true

class ProgrammingLanguagesController < ApplicationController
  def index; end

  def search
    @programming_languages = params[:query].strip.present? ? ProgrammingLanguage.search(params[:query]) : []

    respond_to do |format|
      format.turbo_stream
    end
  end
end
