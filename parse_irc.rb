require_relative 'message'

require_relative 'server_maps'

require_relative 'line_parsers'
require_relative 'log_parsers'

require 'csv'

out = ARGV[0] || 'logs.csv'

CSV.open(out, 'w') do |csv|
  csv << Message.csv_header

  # @type var parser: _LogParser

=begin
  parser = TextualLogParser.new(
    TryLineParsers.new(TextualLineParser.new, TextualSlowLineParser.new),
    ServerMaps::OLDER_MAC
  )
  parser.parse('../ircdev/2013.08.25-2015.03.16/') do |msg|
    csv << msg.to_csv
  end

  parser = HexchatOldLogParser.new(
    HexchatOldLineParser.new,
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

  parser = LimechatLogParser.new LimechatLineParser.new, ServerMaps::LIMECHAT
  parser.parse '../ircdev/2016.09.05-2016.11.30/' do |msg|
    csv << msg.to_csv
  end

  parser = HexchatNewLogParser.new HexchatNewLineParser.new, ServerMaps::HEXCHAT
  parser.parse '../ircdev/2017.01.08-2017.11.12' do |msg|
    csv << msg.to_csv
  end
=end

  parser = HexchatThinkpadLogParser.new HexchatDotLogLineParser.new, ServerMaps::HEXCHAT
  parser.parse '../ircdev/2017.11.14-2019.03.26-thinkpad' do |msg|
    csv << msg.to_csv
  end
end
