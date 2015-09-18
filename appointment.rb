require 'date'

# Edit your credentials.
first_name = 'Lisa'.upcase
last_name = 'Simpson'.upcase
birth_month = sprintf("%02d", 1) # 1 => January
birth_day = sprintf("%02d", 1) # 1 => 1st
birth_year = 1987
license_number = 'F1234567'
area_code = 415
tel_prefix = 555
tel_suffix = 9999

# Fill in any pre-excluded DMVs, such as far away places that keep showing up.
# Excluding them from the input is usually the smarter route.
EXCLUDES = [ "Lancaster", "Norco", "Pomona", "Victorville" ]

# Highlighted date regexp
HIGHLIGHT = /(June 29|June 30), 2010/

# You're ready to go! See README for how to run it.

# Tested on vanilla Snow Leopard.

# Developer override settings.
begin
  dev_settings = open(File.expand_path('~/.dmvrc'), File::RDONLY)
  first_name = dev_settings.gets.chomp
  last_name = dev_settings.gets.chomp
  birth_month = dev_settings.gets.chomp
  birth_day = dev_settings.gets.chomp
  birth_year = dev_settings.gets.chomp
  license_number = dev_settings.gets.chomp
  area_code = dev_settings.gets.chomp
  tel_prefix = dev_settings.gets.chomp
  tel_suffix = dev_settings.gets.chomp
rescue
  nil
end

class String
  def titleize
    capitalize.gsub(/\b([a-z])/){|l| l.upcase}
  end
end

offices = []

STDOUT.sync = true
puts <<head
<html>
<style type="text/css">
body { font-family: georgia; color: #ff50a4; background-color: beige }
div.office { float: left; padding: 2px }
div.office a.success { color: #c0a4c2 }
div.office a.failure { color:red }
div.office a.highlight, div.office.highlight { color: #55A6DE; font-weight: bold }
div.office a.excluded { color: grey }
div.office.legend { overflow: auto; width: 100% }
div.office.legend.end { padding-bottom: 15px }
div.office.end { clear: left }
</style>
</head>
<body>
<div class="office legend end"><b>Searching for appointments...</b></div>

<div class="office legend">Ideal Range:</div>
<div class="office legend end highlight">/#{HIGHLIGHT.source}/</div>

<div class="office legend">Legend:</div>
<div class="office legend"><a href="#" class="highlight">Ideal Appointment</a></div>
<div class="office legend end"><a href="#" class="success">Appointment Available</a></div>

<div class="office legend end">Mouse over a location to see their earliest appointment date.</div>
<div class="office legend end">Click on a location to book an appointment.</div>
head

office_index = 0
while line = STDIN.gets
  if line =~ /value=\"(\d+)\">(([A-Z]+\s?)+)/
    office_id = $1
    office_name = $2.titleize
    puts "\n<!-- name: #{office_name} -->\n"

    if ! EXCLUDES.include?(office_name)
      url = "https://www.dmv.ca.gov/foa/findDriveTest.do?"
      data = "birthDay=#{birth_day}&" +
	"birthMonth=#{birth_month}&" +
	"birthYear=#{birth_year}&" +
	"dlNumber=#{license_number}&" +
	"firstName=#{first_name}&" +
	"lastName=#{last_name}&" +
	"numberItems=1&" +
	"officeId=#{office_id}&" +
	"requestedTask=DT&resetCheckFields=true&" +
	"telArea=#{area_code}&" +
	"telPrefix=#{tel_prefix}&" +
	"telSuffix=#{tel_suffix}"
      out = `curl -s "#{url}" --data "#{data}"`
      sleep 1

      if out =~ /<p class="alert">(\w+[,]\s+\w+\s+\w+,\s+\w+)/
        office_date = $1
        offices.push({
          :id => office_id.to_i,
          :name => office_name,
	  :date => office_date,
	  :index => office_index
        })
        office_end = office_index % 5 == 0 ? ' end' : ''
        office_index = office_index + 1

        office_class = 'success'
        if office_date =~ HIGHLIGHT
          office_class = office_class + ' highlight'
        end

        puts "<div class=\"office#{office_end}\"><a class=\"#{office_class}\" href=\"#{url}\" title=\"#{office_date}\">#{office_name}</a></div>"
      end
    end
  end
end

puts <<foot
<div class="office legend end"><!-- Filler --></div>
<div class="office legend end">Search complete.</div>
</body>
</html>
foot
