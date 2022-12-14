# frozen_string_literal: true

require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "time"
require "date"

SAMPLE_FILE_PATH = "event_attendees.csv"
TEMPLATE_LETTER_PATH = "form_letter.erb"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue Google::Apis::ClientError
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"
  File.open(filename, "w") { |file| file.puts form_letter }
end

def format_phone_number(phone_number)
  "#{phone_number[0, 3]}-#{phone_number[3, 3]}-#{phone_number[6, 4]}"
end

def clean_phone_number(phone_number)
  parsed_number = phone_number.split("").select { |x| x =~ /\d/ }.join

  if parsed_number.length == 10
    format_phone_number(parsed_number)
  elsif parsed_number.length == 11 && parsed_number.start_with?("1")
    format_phone_number(parsed_number[1..10])
  else
    "We don't have a valid phone number on file for you. Add your number today to sign up for text alerts!"
  end
end

def clean_reg_time(reg_time)
  Time.strptime(reg_time, "%m/%d/%y %H:%M")
end

def wday_format(day)
  %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday][day]
end

def print_regtime_data(hours_tally)
  puts "The most popular registration times are:"
  puts "  Hour\t\tRegistrations"
  hours_tally.sort_by(&:last).reverse.to_h.each do |hour, count|
    puts("  #{hour.to_s.rjust(2, '0')}:00\t\t#{count}")
  end
end

def print_regday_data(days_tally)
  puts "The most popular registration days are:"
  puts "  Day\t\tRegistrations"
  days_tally.sort_by(&:last).reverse.to_h.each do |day, count|
    puts("  #{wday_format(day)}\t#{count}")
  end
end

def manage_event
  puts "Event Manager Initialized."

  # Open attendees file and initalize letter template
  attendee_data = CSV.open(
    SAMPLE_FILE_PATH,
    headers: true,
    header_converters: :symbol
  )
  template_letter = File.read(TEMPLATE_LETTER_PATH)
  erb_template = ERB.new template_letter

  # Initalize structures for storing registration data
  hours_tally = Hash.new(0)
  days_tally = Hash.new(0)

  # Process each attendee and generate personalized thank you
  attendee_data.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    phone_number = clean_phone_number(row[:homephone])
    reg_time = clean_reg_time(row[:regdate])

    hours_tally[reg_time.hour] += 1
    days_tally[reg_time.wday] += 1

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id, form_letter)
  end

  # Print analysis of registration times
  print_regtime_data(hours_tally)
  print_regday_data(days_tally)
end

manage_event
