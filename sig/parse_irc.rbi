Networks::RIZON: String
Networks::WHAT_NETWORK: String
Networks::FREENODE: String
Networks::ANIMEBYTES: String
Networks::IRCHIGHWAY: String
Networks::INSTALLGENTOO: String
Networks::ESPER: String
Networks::QUAKENET: String
Networks::TWITCH: String
Networks::UNDERNET: String
Networks::USTREAM: String
Networks::SUSHIGIRL: String

type server_map = Hash<String, String>

ServerMaps::OLDER_MAC: server_map
ServerMaps::OLD_WINDOWS: server_map
ServerMaps::OLD_MAC: server_map
ServerMaps::LIMECHAT: server_map
ServerMaps::FREEBSD_HEXCHAT: server_map

class Message
  @server: String
  @channel: String?
  @time: Time
  @nick: String?
  @message: String

  def initialize: (Time, String?, String) -> any

  def server: -> String
  def server=: (String) -> void
  def channel: -> String?
  def channel=: (String) -> void
  def time: -> Time
  def nick: -> String?
  def message: -> String

  def self.csv_header: -> Array<csv_value>
  def to_csv: -> Array<csv_value>
end

## Line parsers

interface _LineParser
  def parse_line: (String, String) -> Message?
end

class BaseLineParser
  def strptime: (String, String) -> Time?
  def msg_regexp: -> Regexp
  def parse_msg: (String) -> any # Array<String>?
  def parse_time: (String, String) -> Array<any>?
  def parse_line: (String, String) -> Message?
end

class TryLineParsers
  @parsers: Array<_LineParser>
  def initialize: (*_LineParser) -> any
  def parse_line: (String, String) -> Message?
end

class LimechatLineParser < BaseLineParser
end

class TextualSlowLineParser < BaseLineParser
end

class TextualLineParser < BaseLineParser
end

class HexchatOldLineParser < BaseLineParser
end

class HexchatDotLogLineParser < BaseLineParser
end

## Log parsers

interface _LogParser
  def parse: (String) { (Message) -> any } -> any
end

class BaseLogParser
  @line_parser: _LineParser

  def messages_in: (String, any) { (Message) -> any } -> void
  def entries_in: (String) { (String) -> any } -> void
end

class LimechatLogParser < BaseLogParser
  @line_parser: _LineParser
  @server_map: server_map

  def initialize: (_LineParser, server_map) -> any
  def parse: (String) { (Message) -> any } -> any

  def dm_log: (String) -> Array<String>
  def channel_log: (String, String) -> Array<String>
end

class TextualLogParser < BaseLogParser
  @line_parser: _LineParser
  @server_map: server_map

  def initialize: (_LineParser, server_map) -> any
  def parse: (String) { (Message) -> any } -> any
end

class HexchatOldLogParser < BaseLogParser
  @line_parser: _LineParser
  @dotlog_parser: _LineParser
  @server_map: server_map

  def initialize: (_LineParser, _LineParser, server_map) -> any
  def parse: (String) { (Message) -> any } -> any

  def directories_in: (String) { (String) -> any } -> void
  def files_in: (String) { (String) -> any } -> void
  def messages_in_dotlog: (String, String) { (Message) -> any } -> void
end
