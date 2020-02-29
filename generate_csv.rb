require 'csv'
require 'ffaker'

# Before execute $ mkdir tmp
CSV.open('tmp/test.csv', 'wb') do |csv|
  csv << %i[id name email address job]
  10_000.times do |n|
    csv << [n, FFaker::NameJA.name, FFaker::Internet.email, FFaker::AddressJA.address, FFaker::JobJA.title]
  end
end
