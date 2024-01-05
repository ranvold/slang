# frozen_string_literal: true

class CreateProgrammingLanguages < ActiveRecord::Migration[7.1]
  def change
    create_table :programming_languages do |t|
      t.string :name
      t.string :type
      t.string :designed_by

      t.timestamps
    end
    add_index :programming_languages, :name, unique: true
    add_index :programming_languages, :type
    add_index :programming_languages, :designed_by
  end
end
