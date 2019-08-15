require_relative 'message'

class SlowTextualLineParser
  def parse_time day, msg
    m = msg.match(/\[(.+?)\]/)
    return if m.nil?
    t = m[1]

    d = "#{day} #{t} CET"
    date =
      strptime(d, '%Y-%m-%d %H.%M %Z') ||
      strptime(d, '%Y-%m-%d %H:%M %Z') ||
      strptime(d, '%Y-%m-%d %H:%M:%S %Z')

    return if date.nil?

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

class TextualLineParser
  def parse_line msg
    d = msg.match /\[(.+?)\]/
    return unless d

    date = strptime(d[1], '%Y-%m-%dT%H:%M:%S%z')
    return unless date
    date = date.to_time

    rest = msg[(d[0].length + 1)..-1]

    m = rest.match /^<(.+?)>(.*)$/

    if m.nil?
      Message.new date, nil, rest.strip
    else
      Message.new date, m[1], m[2].strip
    end
  end
end

class OldHexchatLineParser
  def parse_line day, msg
    d = msg.match(/\[(.+?)\]/)
    return unless d

    date = strptime "#{day} #{d[1]} CET", '%Y-%m-%d %H:%M:%S %Z'
    return unless date
    date = date.to_time

    rest = msg[(d[0].length + 1)..-1]
    m = rest.match /^<(.+?)>(.*)$/

    if m.nil?
      Message.new date, nil, rest.strip
    else
      Message.new date, m[1], m[2].strip
    end
  end
end

class TextualParser
  def initialize line_parser, slow_line_parser, server_map
    @line_parser = line_parser
    @slow_line_parser = slow_line_parser
    @server_map = server_map
  end

  def parse_line day, msg
    @line_parser.parse_line(msg) || @slow_line_parser.parse_line(day, msg)
  end

  def parse base
    servers(base) do |server, path|
      dir_a(File.join(path, 'Channels')).each do |channel|
        raise channel unless channel.start_with? '#'

        days(File.join(path, 'Channels', channel)) do |day, msg|
          #msg = @line_parser.parse_line(msg) || @slow_line_parser.parse_line(day, msg)
          msg = parse_line day, msg
          next unless msg
          msg.server = server
          msg.channel = channel
          yield msg
        end
      end

      dir_a(File.join(path, 'Queries')).each do |nick|
        days(File.join(path, 'Queries', nick)) do |day, msg|
          #msg = @line_parser.parse_line day, msg
          msg = parse_line day, msg
          next unless msg
          msg.server = server
          msg.channel = nick
          yield msg
        end
      end

      days(File.join(path, 'Console')) do |day, msg|
        #msg = @line_parser.parse_line day, msg
        msg = parse_line day, msg
        next unless msg
        msg.server = server
        yield msg
      end
    end
  end

  private

  def servers base
    dir_a(base).each do |dir|
      server = @server_map[dir]
      next unless server
      yield server, File.join(base, dir)
    end
  end

  def days path
    dir_a(path).each do |f|
      next if f.match /copia/

      day = f[0..-5]
      fname = File.join path, f

      File.open(fname, 'r') do |f|
        f.each_line do |line|
          yield day, line
        end
      end
    end
  end
end
