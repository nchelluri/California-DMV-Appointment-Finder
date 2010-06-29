require 'date'

first_name = 'Alice'.upcase
last_name = 'Calloo'.upcase
birth_day = sprintf("%02d", 1)
birth_month = sprintf("%02d", 1)
birth_year = 1970
license_number = 'F1234567'
area_code = 415
tel_prefix = 555
tel_suffix = 1234

class String
  def titleize
    capitalize.gsub(/\b([a-z])/){|l| l.upcase}
  end
end

offices = []

STDOUT.sync = true
print "Searching for appointments..."

while line = STDIN.gets
  if line =~ /value=\"(\d+)\">(([A-Z]+\s?)+)/
    officeId = $1
    officeName = $2.titleize
    url = "https://eg.dmv.ca.gov/foa/findDriveTest.do?birthDay=#{birth_day}&birthMonth=#{birth_month}&birthYear=#{birth_year}&dlNumber=#{license_number}&firstName=#{first_name}&lastName=#{last_name}&numberItems=1&officeId=#{officeId}&requestedTask=DT&resetCheckFields=true&telArea=#{area_code}&telPrefix=#{tel_prefix}&telSuffix=#{tel_suffix}"
#    puts url
    out = `curl -s "#{url}"`

    if out =~ /<p class="alert">\s+(\w+[,]\s+\w+\s+\w+,\s+\w+)/
      offices.push({
        :id => officeId,
        :name => officeName,
	:date => $1
      })
      print '.'
    else
      # puts "\nFound nothing at #{officeName}."
    end

    if out =~ /(Tuesday, June 29)/ or out =~ /(Wednesday, June 30)/
      if ! [ "Norco", "Pomona", "Victorville" ].include?(officeName)
       puts "\n*** Candidate: #{officeName}: #{$1}."
      else
        print "*"
      end
    end
  end
end

puts "\nCompleted search.\n\n"

# offices.sort! do |a,b|
#  Date.parse(a[:date],true) <=> Date.parse(b[:date],true)
# end

# offices.each do |office|
#  puts office[:name] + ': ' + office[:date] + ' [' + office[:id] + ']'
# end