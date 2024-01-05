# frozen_string_literal: true

raw_data = JSON.parse(File.read('db/data/data.json'))

ProgrammingLanguage.transaction do
  raw_data.each do |row|
    ProgrammingLanguage.create!(name: row['Name'], type: row['Type'], designed_by: row['Designed by'])
  end
end
