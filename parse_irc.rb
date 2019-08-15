require_relative 'message'

require_relative 'parser_old_mac'
require_relative 'parser_wut'

require 'csv'

# parser = OldMacParser.new OldMacLineParser.new
# CSV.open('2013.08.25-2015.03.16.csv', 'w') do |csv|
#   csv << ['server', 'channel', 'time', 'nick', 'message']
#   parser.parse('../ircdev/2013.08.25-2015.03.16/') do |msg|
#     csv << [msg.server, msg.channel, msg.time, msg.nick, msg.message]
#   end
# end

parser = Old2Parser.new OldMacLineParser.new, DotLogLineParser.new
CSV.open('2015.03.22-2015.06.06.csv', 'w') do |csv|
  csv << Message.csv_header
  parser.parse('../ircdev/2015.03.22-2015.06.06/') do |msg|
    csv << msg.to_csv
  end
end
