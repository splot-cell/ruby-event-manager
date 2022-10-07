require "csv"

puts "Event Manager Initialized!"

SAMPLE_FILE_PATH = "event_attendees.csv"

abort unless File.exist?(SAMPLE_FILE_PATH)

contents = CSV.open(SAMPLE_FILE_PATH, headers: true, header_converters: :symbol)
contents.each do |row|
  name = row[:first_name]
  puts name
end
