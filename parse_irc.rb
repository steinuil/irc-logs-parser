require_relative 'message'

require_relative 'server_maps'

require_relative 'parser_textual'
require_relative 'parser_wut'

require 'csv'

out = ARGV[0] || 'logs.csv'

CSV.open(out, 'w') do |csv|
  csv << Message.csv_header

  parser = TextualParser.new TryBothTextualLineParsers.new, ServerMaps::OLDER_MAC
  parser.parse('../ircdev/2013.08.25-2015.03.16/') do |msg|
    csv << msg.to_csv
  end

  parser = Old2Parser.new(
    OldHexchatLineParser.new,
    DotLogLineParser.new,
    ServerMaps::OLD_WINDOWS
  )
  parser.parse('../ircdev/2015.03.22-2015.06.06/') do |msg|
    csv << msg.to_csv
  end

  parser = TextualParser.new TextualLineParser.new, ServerMaps::OLD_MAC
  parser.parse('../ircdev/2015.09.10-2016.01.24/') do |msg|
    csv << msg.to_csv
  end
end
