require 'date'

# Edit your credentials.
first_name = 'Lisa'.upcase
last_name = 'Simpson'.upcase
birth_month = sprintf("%02d", 2) # 1 => January
birth_day = sprintf("%02d", 19) # 1 => 1st
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
puts '<head><meta http-equiv="refresh" content="1" /></head>'
puts '<body>'
print "Searching for appointments...<br><br>"

while line = STDIN.gets
  if line =~ /value=\"(\d+)\">(([A-Z]+\s?)+)/
    officeId = $1
    officeName = $2.titleize
    if EXCLUDES.include?(officeName)
      puts "Skipping excluded office #{officeName}.<br><br>"
      next
    end

    url = "https://eg.dmv.ca.gov/foa/findDriveTest.do?birthDay=#{birth_day}&birthMonth=#{birth_month}&birthYear=#{birth_year}&dlNumber=#{license_number}&firstName=#{first_name}&lastName=#{last_name}&numberItems=1&officeId=#{officeId}&requestedTask=DT&resetCheckFields=true&telArea=#{area_code}&telPrefix=#{tel_prefix}&telSuffix=#{tel_suffix}"
    out = `curl -s "#{url}"`
    sleep 1

    if out =~ /<p class="alert">\s+(\w+[,]\s+\w+\s+\w+,\s+\w+)/
      offices.push({
        :id => officeId,
        :name => officeName,
	:date => $1
      })
      puts "Found appointment at #{officeName} on #{$1}.<br>"
      if $1 =~ HIGHLIGHT
        puts "\n<br>*** Candidate: #{officeName}: #{$1}.<br>"
        puts "***<br>\n***<br>\n"
      end
    else
      puts "Found no appointments at #{officeName}.<br>"
    end

    id = officeName.split(' ').first
    puts "<a id=\"#{id}\" name=\"#{id}\" href=\"#{url}\">ClickIt</a><br>"
    puts "<script>window.location.hash = '#{id}';</script>"
    puts '<br><br>'
  end
end

puts "\n<br>Completed search.\n\n<br><br>"

offices.sort! do |a,b|
  Date.parse(a[:date],true) <=> Date.parse(b[:date],true)
end

offices.each do |office|
  puts office[:name] + ': ' + office[:date] + ' [' + office[:id] + ']' + '<br>'
end

