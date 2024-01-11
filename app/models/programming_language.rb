# frozen_string_literal: false

class ProgrammingLanguage < ApplicationRecord
  self.inheritance_column = nil

  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  validates :designed_by, presence: true

  # Solution based on regex expressions and generating sql query on fly
  def self.search(query)
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
            (type ~* #{query[:in_different_fields]} AND
            designed_by ~* #{query[:in_different_fields]}))
            #{negative_sql_condition(query[:negative]) if query[:negative].present?}
        ORDER BY relevance DESC;
      SQL
    )
  end

  def self.negative_sql_condition(negative)
    <<-SQL
            AND
            name !~* #{negative} AND
            type !~* #{negative} AND
            designed_by !~* #{negative}
    SQL
  end

  def self.any_order_sql_condition(in_any_order)
    <<-SQL
            #{name_any_order_sql_condition(in_any_order)} OR
            #{type_any_order_sql_condition(in_any_order)} OR
            #{designed_by_any_order_sql_condition(in_any_order)}
    SQL
  end

  def self.name_any_order_sql_condition(in_any_order)
    sql = ''
    in_any_order.each do |word|
      sql << <<-SQL
        name ~* #{word}
      SQL
    end
    prepare_any_order_sql_condition(sql)
  end

  def self.type_any_order_sql_condition(in_any_order)
    sql = ''
    in_any_order.each do |word|
      sql << <<-SQL
        type ~* #{word}
      SQL
    end
    prepare_any_order_sql_condition(sql)
  end

  def self.designed_by_any_order_sql_condition(in_any_order)
    sql = ''
    in_any_order.each do |word|
      sql << <<-SQL
        designed_by ~* #{word}
      SQL
    end
    prepare_any_order_sql_condition(sql)
  end

  def self.prepare_any_order_sql_condition(sql)
    sql.split("\n").map(&:strip).join(' AND ')
  end
end
