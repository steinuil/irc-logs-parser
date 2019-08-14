require_relative 'message'

require_relative 'parser_old_mac'

require 'csv'

parser = OldMacParser.new OldMacLineParser.new
CSV.open('2013.08.25-2015.03.16.csv', 'w') do |csv|
  csv << ['server', 'channel', 'time', 'nick', 'message']
  parser.parse('../ircdev/2013.08.25-2015.03.16/') do |msg|
    csv << [msg.server, msg.channel, msg.time, msg.nick, msg.message]
  end
end

