require_relative 'message'

require_relative 'parser_old_mac'
require_relative 'parser_wut'

require 'csv'

out = ARGV[0] || 'logs.csv'

CSV.open(out, 'w') do |csv|
  csv << Message.csv_header

  #parser = OldMacParser.new OldMacLineParser.new
  #parser.parse('../ircdev/2013.08.25-2015.03.16/') do |msg|
  #  csv << msg.to_csv
  #end

  parser = Old2Parser.new OldMacLineParser.new, DotLogLineParser.new
  parser.parse('../ircdev/2015.03.22-2015.06.06/') do |msg|
    csv << msg.to_csv
  end
end
