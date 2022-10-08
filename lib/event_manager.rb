require "csv"
require "google/apis/civicinfo_v2"
require "erb"

SAMPLE_FILE_PATH = "event_attendees.csv"
TEMPLATE_LETTER_PATH = "form_letter.erb"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: ["legislatorUpperBody", "legislatorLowerBody"]
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

puts "Event Manager Initialized."

# Open attendees file and initalize letter template
attendee_data = CSV.open(
  SAMPLE_FILE_PATH,
  headers: true,
  header_converters: :symbol
)
template_letter = File.read(TEMPLATE_LETTER_PATH)
erb_template = ERB.new template_letter

attendee_data.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"
  File.open(filename, "w"){ |file| file.puts form_letter }
end
