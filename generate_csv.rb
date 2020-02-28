# frozen_string_literal: true

require 'csv'
require 'ffaker'

schema = lambda do |id = nil|
  {
    id: id,
    name: FFaker::NameJA.name,
    email: FFaker::Internet.email,
    address: FFaker::AddressJA.address,
    job: FFaker::JobJA.title
  }
end

header = lambda do
  schema.call.keys
end

row = lambda do |id|
  schema.call(id).values
end

CSV.open('tmp/test.csv', 'wb') do |csv|
  csv << header.call
  10_000.times do |n|
    csv << row.call(n)
  end
end
