require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "time"

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

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"
  File.open(filename, "w"){ |file| file.puts form_letter }
end

def format_phone_number(phone_number)
  "#{phone_number[0, 3]}-#{phone_number[3, 3]}-#{phone_number[6, 4]}"
end

def clean_phone_number(phone_number)
  parsed_number = phone_number.split("").select{ |x| x =~ /\d/ }.join

  if (parsed_number.length == 10)
    format_phone_number(parsed_number)
  elsif (parsed_number.length == 11 && parsed_number.start_with?("1"))
    format_phone_number(parsed_number[1..10])
  else
    "We don't have a valid phone number on file for you. Add your number today to sign up for text alerts!"
  end
end

def clean_reg_time(reg_time)
  Time.strptime(reg_time, "%m/%d/%y %H:%M")
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

hour_registered = Hash.new(0)
day_registered = Hash.new(0)

attendee_data.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  reg_time = clean_reg_time(row[:regdate])

  hour_registered[reg_time.hour] += 1
  day_registered[reg_time.day] += 1

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end

puts "The distribution of registration times is:"
puts "  Hour\tRegistrations"
hour_registered.each{ |hour, count| puts("  #{hour}\t#{count}") }

puts "The distribution of registration days is:"
puts "  Day\tRegistrations"
day_registered.each{ |day, count| puts("  #{day}\t#{count}") }
