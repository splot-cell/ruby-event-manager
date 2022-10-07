require "csv"

puts "Event Manager Initialized!"

SAMPLE_FILE_PATH = "event_attendees.csv"

abort unless File.exist?(SAMPLE_FILE_PATH)

contents = CSV.open(SAMPLE_FILE_PATH, headers: true)
contents.each do |row|
  name = row[2]
  puts name
end
