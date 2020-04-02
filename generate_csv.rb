# frozen_string_literal: true

require 'csv'
require 'ffaker'

# ffaker を違う値にするためには、毎回 hash を初期化する必要がある
schema = lambda do |id = nil|
  {
    id: id,
    name: FFaker::NameJA.name,
    email: FFaker::Internet.email,
    address: FFaker::AddressJA.address,
    job: FFaker::JobJA.title
  }
end

# Before execute $ mkdir tmp
CSV.open('tmp/test.csv', 'wb') do |csv|
  csv << schema.call.keys
  10_000.times do |n|
    csv << schema.call(n).values
  end
end
