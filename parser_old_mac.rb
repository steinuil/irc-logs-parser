require_relative 'message'

class OldMacLineParser
  def parse_time day, msg
    m = msg.match(/\[(.+?)\]/)
    return if m.nil?
    t = m[1]

    d = "#{day} #{t} CET"
    date =
      strptime(d, '%Y-%m-%d %H.%M %Z') ||
      strptime(d, '%Y-%m-%d %H:%M %Z') ||
      strptime(d, '%Y-%m-%d %H:%M:%S %Z') ||
      strptime(t, '%Y-%m-%dT%H:%M:%S%z')
    [date.to_time, msg[(t.length + 3)..-1]]
  end

  def parse_line day, msg
    date, rest = parse_time day, msg
    return if date.nil?

    m = rest.match /^<(.+?)>(.*)$/

    if m.nil?
      Message.new date, nil, rest.strip
    else
      Message.new date, m[1], m[2].strip
    end
  end
end
