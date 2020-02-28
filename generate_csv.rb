require 'csv'
require 'ffaker'

def schema(id = nil)
  {
    id: id,
    name: FFaker::NameJA.name,
    email: FFaker::Internet.email,
    address: FFaker::AddressJA.address,
    job: FFaker::JobJA.title
  }
end

def header
  schema.keys
end

def row(id)
  schema(id).values
end

CSV.open('tmp/test.csv', 'wb') do |csv|
  csv << header
  10_000.times do |n|
    csv << row(n)
  end
end
