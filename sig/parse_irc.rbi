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

ServerMaps::OLDER_MAC: Hash<String, String>
ServerMaps::OLD_WINDOWS: Hash<String, String>
ServerMaps::OLD_MAC: Hash<String, String>
ServerMaps::LIMECHAT: Hash<String, String>
ServerMaps::FREEBSD_HEXCHAT: Hash<String, String>

class Message
  @server: String
  @channel: String?
  @time: Time
  @nick: String?
  @message: String

  def initialize: (Time, String?, String) -> any

  def server: -> String
  def channel: -> String?
  def time: -> Time
  def nick: -> String?
  def message: -> String
end

class BaseLineParser
  def strptime: (String, String) -> Time?
  def msg_regexp: -> Regexp
  def parse_msg: (String) -> any # Array<String>?
  def parse_time: (String, String) -> Array<any>?
  def parse_line: (String, String) -> Message?
end

class TryLineParsers
  @parsers: Array<BaseLineParser>
  def parse_line: (String, String) -> Message?
end

interface _Parser
  def parse: (String) { (Message) -> any } -> any
end

