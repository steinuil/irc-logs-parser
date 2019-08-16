require_relative 'message'

require_relative 'server_maps'

require_relative 'line_parsers'
require_relative 'log_parsers'
require_relative 'parser_wut'

require 'csv'

out = ARGV[0] || 'logs.csv'

CSV.open(out, 'w') do |csv|
  csv << Message.csv_header

  # @type var parser: _LogParser

  parser = TextualLogParser.new(
    TryLineParsers.new(TextualLineParser.new, SlowTextualLineParser.new),
    ServerMaps::OLDER_MAC
  )
  parser.parse('../ircdev/2013.08.25-2015.03.16/') do |msg|
    csv << msg.to_csv
  end

  parser = Old2Parser.new(
    OldHexchatLineParser.new,
    HexchatDotLogLineParser.new,
    ServerMaps::OLD_WINDOWS
  )
  parser.parse('../ircdev/2015.03.22-2015.06.06/') do |msg|
    csv << msg.to_csv
  end

  parser = TextualLogParser.new TextualLineParser.new, ServerMaps::OLD_MAC
  parser.parse('../ircdev/2015.09.10-2016.01.24/') do |msg|
    csv << msg.to_csv
  end

  parser = LimechatLogParser.new LimeChatLineParser.new, ServerMaps::LIMECHAT
  parser.parse '../ircdev/2016.09.05-2016.11.30/' do |msg|
    csv << msg.to_csv
  end
end
