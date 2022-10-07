require "csv"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

puts "Event Manager Initialized!"

SAMPLE_FILE_PATH = "event_attendees.csv"

abort unless File.exist?(SAMPLE_FILE_PATH)

contents = CSV.open(SAMPLE_FILE_PATH, headers: true, header_converters: :symbol)
contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  puts "#{name}\t#{zipcode}"
end
