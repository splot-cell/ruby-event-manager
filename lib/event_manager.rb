require "csv"

def clean_zipcode(zipcode)
  return "00000" if zipcode.nil?

  zipcode.length == 5? zipcode : "00000#{zipcode}"[-5..-1]
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
