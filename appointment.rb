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
EXCLUDES = [ "Lancaster", "Norco", "Pomona", "Victorville" ]

# Highlighted date regexp
HIGHLIGHT = /(June 29|June 30), 2010/

# You're ready to go! See README for how to run it.

# Tested on vanilla Snow Leopard.

class String
  def titleize
    capitalize.gsub(/\b([a-z])/){|l| l.upcase}
  end
end

offices = []

STDOUT.sync = true
puts '<html>'
puts '<style type="text/css">body { font-family: georgia; color: #ff50a4; background-color: beige } div.office { float: left; padding: 2px }'
puts 'div.office a.success { color: #c0a4c2 } div.office a.failure { color:red } div.office a.highlight { color: #55A6DE; } div.office a.excluded { color: grey } div.office.legend { overflow: auto; width: 100% }</style>'
puts '</head>'
puts '<body>'
print "<b>Searching for appointments...</b><br><br>"

print 'Legend:<br>'
print '<div class="office legend"><a href="#" class="highlight">Ideal Appointment</a></div>'
print '<div class="office legend"><a href="#" class="success">Appointment Available</a></div><br>'

print '<br><br><br>Mouse over a location to see the earliest appointment date.<br>'

office_index = 0
while line = STDIN.gets
  if line =~ /value=\"(\d+)\">(([A-Z]+\s?)+)/
    office_id = $1
    office_name = $2.titleize
    puts "\n<!-- name: #{office_name} -->\n"

    if ! EXCLUDES.include?(office_name)
      url = "https://eg.dmv.ca.gov/foa/findDriveTest.do?birthDay=#{birth_day}&birthMonth=#{birth_month}&birthYear=#{birth_year}&dlNumber=#{license_number}&firstName=#{first_name}&lastName=#{last_name}&numberItems=1&officeId=#{office_id}&requestedTask=DT&resetCheckFields=true&telArea=#{area_code}&telPrefix=#{tel_prefix}&telSuffix=#{tel_suffix}"
      out = `curl -s "#{url}"`
      sleep 1

      if out =~ /<p class="alert">\s+(\w+[,]\s+\w+\s+\w+,\s+\w+)/
        office_date = $1
        offices.push({
          :id => office_id.to_i,
          :name => office_name,
	  :date => office_date,
	  :index => office_index
        })
        office_index = office_index + 1

        office_class = 'success'
        if office_date =~ HIGHLIGHT
          office_class = office_class + ' highlight'
        end

      id = office_name.split(' ').first
      puts "<div class=\"office\"><a class=\"#{office_class}\" id=\"#{id}\" name=\"#{id}\" href=\"#{url}\" title=\"#{office_date}\">#{office_name}</a></div>"
      end
    end
  end
end

puts "\n<div class=\"office legend\"><br><br>Completed search.</div>"


