puts "Event Manager Initialized!"

SAMPLE_FILE_PATH = "event_attendees.csv"

abort unless File.exist?(SAMPLE_FILE_PATH)

puts "Sample file identified"
lines = File.readlines(SAMPLE_FILE_PATH)
lines.each_with_index do |line, index|
  next if index == 0
  columns = line.split(",")
  name = columns[2]
  puts name
end
