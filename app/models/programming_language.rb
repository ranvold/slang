# frozen_string_literal: false

class ProgrammingLanguage < ApplicationRecord
  self.inheritance_column = nil

  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  validates :designed_by, presence: true

  def self.search(raw_query)
    query = prepare_query(raw_query)
    find_by_sql(
      <<-SQL
        SELECT name, type, designed_by,
          CASE
            WHEN #{name_any_order_sql_condition(query[:in_any_order])} THEN 3
            WHEN #{type_any_order_sql_condition(query[:in_any_order])} THEN 2
            WHEN #{designed_by_any_order_sql_condition(query[:in_any_order])} THEN 1
          ELSE 0 END as relevance
        FROM programming_languages
          WHERE
            ((#{any_order_sql_condition(query[:in_any_order])}) OR
            (type ~* '#{query[:in_different_fields]}' AND
            designed_by ~* '#{query[:in_different_fields]}'))
            #{negative_sql_condition(query) if query[:negative].present?}
        ORDER BY relevance DESC;
      SQL
    )
  end

  # rubocop:disable Metrics/AbcSize
  def self.prepare_query(raw_query)
    query = {}
    query[:negative] = raw_query.scan(/-\s?(.*.)/).flatten.map { |word| "\\m#{word}" }.join('|')
    positive = raw_query.gsub(/-\s?.*./, '').strip
    exact = positive.scan(/"([^"]*)"/).flatten.map { |word| "\\m#{word}\\M" }
    rest = positive.gsub(/".*?"/, '').split(' ').map { |word| "\\m#{word}" }
    mapped = rest + exact
    query[:in_any_order] = mapped
    query[:in_different_fields] = mapped.join('|')
    query
  end
  # rubocop:enable Metrics/AbcSize

  def self.negative_sql_condition(query)
    <<-SQL
            AND
            name !~* '#{query[:negative]}' AND
            type !~* '#{query[:negative]}' AND
            designed_by !~* '#{query[:negative]}'
    SQL
  end

  def self.any_order_sql_condition(query)
    <<-SQL
            #{name_any_order_sql_condition(query)} OR
            #{type_any_order_sql_condition(query)} OR
            #{designed_by_any_order_sql_condition(query)}
    SQL
  end

  def self.name_any_order_sql_condition(query)
    sql = ''
    query.each do |word|
      sql << <<-SQL
        name ~* '#{word}'
      SQL
    end
    prepare_any_order_sql_condition(sql)
  end

  def self.type_any_order_sql_condition(query)
    sql = ''
    query.each do |word|
      sql << <<-SQL
        type ~* '#{word}'
      SQL
    end
    prepare_any_order_sql_condition(sql)
  end

  def self.designed_by_any_order_sql_condition(query)
    sql = ''
    query.each do |word|
      sql << <<-SQL
        designed_by ~* '#{word}'
      SQL
    end
    prepare_any_order_sql_condition(sql)
  end

  def self.prepare_any_order_sql_condition(sql)
    sql.split("\n").map(&:strip).join(' AND ')
  end
end
