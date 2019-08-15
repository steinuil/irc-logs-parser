require_relative 'message'

require_relative 'server_maps'

require_relative 'parser_textual'
require_relative 'parser_wut'

require 'csv'

out = ARGV[0] || 'logs.csv'

CSV.open(out, 'w') do |csv|
  csv << Message.csv_header

  parser = TextualParser.new OldMacLineParser.new, ServerMaps::OLDER_MAC
  parser.parse('../ircdev/2013.08.25-2015.03.16/') do |msg|
    csv << msg.to_csv
  end

  parser = Old2Parser.new OldMacLineParser.new, DotLogLineParser.new, ServerMaps::OLD_WINDOWS
  parser.parse('../ircdev/2015.03.22-2015.06.06/') do |msg|
    csv << msg.to_csv
  end
end
