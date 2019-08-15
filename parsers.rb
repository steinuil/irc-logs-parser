require_relative 'message'

class BaseLineParser
  def parse_msg rest
    m = rest.match msg_regexp
    m and m[1..2]
  end

  def parse_line time_info, msg
    date, rest = parse_time(time_info, msg) || return

    date = date.to_time

    nick, text = parse_msg rest
    if nick
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
  end
end

class LimeChatLineParser < BaseLineParser
  def parse_time day, msg
    date = strptime("#{day} #{msg[0..4]} CET", '%Y-%m-%d %H:%M %Z') || return
    [date, msg[6..-1]]
  end

  def msg_regexp
    /^([^\s]+?): (.*)$/
  end
end

class SlowTextualLineParser < BaseLineParser
  def parse_time day, msg
    t = msg.match(/\[(.+?)\]/)
    return unless t
    t = t[1]

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
    d = msg.match /\[(.+?)\]/
    return unless d

    date = strptime(d[1], '%Y-%m-%dT%H:%M:%S%z')
    return unless date

    [date, msg[(d[0].length + 1)..-1]]
  end

  def msg_regexp
    /^<(.+?)>(.*)$/
  end
end

class OldHexchatLineParser < BaseLineParser
  def parse_time day, msg
    d = msg.match(/\[(.+?)\]/)
    return unless d

    date = strptime "#{day} #{d[1]} CET", '%Y-%m-%d %H:%M:%S %Z'
    return unless date

    rest = msg[(d[0].length + 1)..-1]
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
