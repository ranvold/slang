# frozen_string_literal: true

module ProgrammingLanguage::Operation
  class Search < Trailblazer::Operation
    step :prepare_plus_signs
    step :prepare_negative_words
    step :prepare_positive_words
    step :map_exact_and_rest
    step :sanitaze_params

    def prepare_plus_signs(ctx, raw_query:, **)
      ctx[:query] = raw_query.gsub(/\+/, '\\\+')
    end

    def prepare_negative_words(ctx, query:, **)
      ctx[:negative] = query.scan(/\B-\s?(\S+)/).flatten.map { |word| "\\m#{word}" }.join('|')
    end

    def prepare_positive_words(ctx, query:, **)
      ctx[:positive] = query.gsub(/\B-\s?\S+/, '').strip
    end

    def map_exact_and_rest(ctx, positive:, **)
      exact = positive.scan(/"([^"]*)"/).flatten.map { |word| "\\m#{word}\\M" }
      rest = positive.gsub(/".*?"/, '').split(' ').map { |word| "\\m#{word}" }
      ctx[:exact_and_rest] = rest + exact
    end

    def sanitaze_params(ctx, negative:, exact_and_rest:, **)
      query = {}
      query[:negative] = ActiveRecord::Base.connection.quote(negative) if negative.present?
      query[:in_any_order] = exact_and_rest.map { |word| ActiveRecord::Base.connection.quote(word) }
      query[:in_different_fields] = ActiveRecord::Base.connection.quote(exact_and_rest.join('|'))
      ctx[:prepared_query] = query
    end
  end
end
