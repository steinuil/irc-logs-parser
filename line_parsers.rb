require 'date'
require_relative 'message'

class BaseLineParser
  def strptime date, fmt
    DateTime.strptime(date, fmt).to_time rescue nil
  end

  def parse_time time_info, msg
    raise NotImplementedError
  end

  def msg_regexp
    raise NotImplementedError
  end

  def parse_msg rest
    m = rest.match msg_regexp
    m and m[1..2]
  end

  def parse_line time_info, msg
    d = parse_time(time_info, msg) || return
    # have to do this not to get FallbackAny in steep
    date, rest = d[0], d[1]

    m = parse_msg rest
    if m
      nick, text = m[0], m[1]
      Message.new date, nick, text.strip
    else
      Message.new date, nil, rest.strip
    end
  end
end

class TryLineParsers
  def initialize *parsers
    @parsers = parsers
  end

  def parse_line day, msg
    @parsers.each do |parser|
      out = parser.parse_line(day, msg)
      return out if out
    end
    nil
  end
end

class LimechatLineParser < BaseLineParser
  def parse_time day, msg
    date = strptime("#{day} #{msg[0..4]} CET", '%Y-%m-%d %H:%M %Z') || return
    [date, msg[6..-1]]
  end

  def msg_regexp
    /^([^\s]+?): (.*)$/
  end
end

class TextualSlowLineParser < BaseLineParser
  def parse_time day, msg
    m = msg.match(/\[(.+?)\]/) || return
    t = m[1] || return

    d = "#{day} #{t} CET"
    date =
      strptime(d, '%Y-%m-%d %H.%M %Z') ||
      strptime(d, '%Y-%m-%d %H:%M %Z') ||
      strptime(d, '%Y-%m-%d %H:%M:%S %Z')

    return unless date

    [date, msg[(t.length + 3)..-1]]
  end

  def msg_regexp
    /^<(.+?)>(.*)$/
  end
end

class TextualLineParser < BaseLineParser
  def parse_time _day, msg
    m = msg.match(/\[(.+?)\]/) || return
    d = m[1] || return

    date = strptime(d, '%Y-%m-%dT%H:%M:%S%z') || return

    [date, msg[(d.length + 3)..-1]]
  end

  def msg_regexp
    /^<(.+?)>(.*)$/
  end
end

class HexchatOldLineParser < BaseLineParser
  def parse_time day, msg
    m = msg.match(/\[(.+?)\]/) || return
    d = m[1] || return

    date = strptime "#{day} #{d} CET", '%Y-%m-%d %H:%M:%S %Z'
    return unless date

    rest = msg[(d.length + 3)..-1]
    [date, rest]
  end

  def msg_regexp
    /^<(.+?)>(.*)$/
  end
end

class HexchatDotLogLineParser < BaseLineParser
  def parse_time year, msg
    date = strptime "#{year} #{msg[0..14]} CET", '%Y %b %d %H:%M:%S %Z'
    return unless date

    rest = msg[16..-1]
    [date, rest]
  end

  def msg_regexp
    /^<(.+?)>(.*)$/
  end
end
