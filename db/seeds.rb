# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

raw_data = JSON.parse(File.read('db/data/data.json'))

ProgrammingLanguage.transaction do
  raw_data.each do |row|
    ProgrammingLanguage.create!(name: row['Name'], type: row['Type'], designed_by: row['Designed by'])
  end
end
