puts "Event Manager Initialized!"

SAMPLE_FILE_PATH = "event_attendees.csv"

abort unless File.exist?(SAMPLE_FILE_PATH)

puts "Sample file identified"
lines = File.readlines(SAMPLE_FILE_PATH)
lines.each do |line|
  columns = line.split(",")
  print columns
  puts
end
