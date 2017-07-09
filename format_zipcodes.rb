require 'csv'
require 'bigdecimal'

zipcode_csv = CSV.open('zipcodes.csv', 'rb', headers: true, header_converters: :symbol)
zipcodes = zipcode_csv.read.each do |row|
  row[:latitude] = (BigDecimal.new(row[:latitude]) * 100).to_i
  row[:longitude] = (BigDecimal.new(row[:longitude]) * 100).to_i
end
zipcode_csv.close

min_latitude = zipcodes.map { |row| row[:latitude] }.min
min_longitude = zipcodes.map { |row| row[:longitude] }.min

zipcodes.each do |row|
  row[:latitude] -= min_latitude
  row[:longitude] -= min_longitude
end

formatted_zipcode_csv = CSV.open('formatted_zipcodes.csv', 'wb')
zipcodes.each { |row| formatted_zipcode_csv << row }
formatted_zipcode_csv.close
