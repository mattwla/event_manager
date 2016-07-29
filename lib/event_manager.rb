require "csv"
require "sunlight/congress"
require "erb"
require "time"

puts "Event manager initialized!"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"


def clean_zipcode(zipcode)
	zipcode = zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letter(id, form_letter)
	Dir.mkdir("output") unless Dir.exists?("output")
	filename = "output/thanks_#{id}.html"

	File.open(filename, 'w') do |file|
		file.puts form_letter
	end
end

def clean_phone_number(number)
	number = number.to_s.gsub(/\D/, "")

	if number.length < 10 || number.length > 11
		return ""
	elsif number.length == 10
		return number
	elsif number.length == 11
		return "" if number[0] != "1"
		return number [0] = "" if number[0] == 1
	end 

end

def process_time(time)
	return Time.parse(time.split("").last(5).join("")).strftime("%H")
end

def process_day_of_week(date)
	days_of_week = {0 => "sunday", 1 => "monday", 2 => "tuesday", 3 => "wednesday", 4 => "thursday", 5 => "friday", 6 => "saturday"}
	month = ""
	day = ""
	year = ""
	output = ""
	idx = 0
	until date[idx] == "/"
		month << date[idx]
		idx += 1
	end
	idx += 1
	until date[idx] == "/"
		day << date[idx]
		idx += 1
	end
	idx += 1
	2.times do
		year << date[idx]
		idx += 1
	end

	output = day + "/" + month + "/" + year
	
	days_of_week[Time.parse(output).wday]



end


contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
	id = row[0]
	name = row[:first_name]
	homephone = clean_phone_number(row[:homephone])
	zipcode = clean_zipcode(row[:zipcode])
	time = process_time(row[:regdate])
	day_of_week = process_day_of_week(row[:regdate])


	legislators = legislators_by_zipcode(zipcode)
	form_letter = erb_template.result(binding)
	save_thank_you_letter(id, form_letter)

	p time
	p day_of_week
	
	end
	

	#puts "#{name} #{zipcode} #{legislators}"
	#puts form_letter


