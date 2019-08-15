require_relative 'message'

class OldMacLineParser
  def parse_time day, msg
    m = msg.match(/\[(.+?)\]/)
    if m.nil?
      #STDERR.puts "invalid msg @ #{day}: #{msg}"
      return
    end
    t = m[1]

    d = "#{day} #{t} CET"
    date =
      strptime(d, '%Y-%m-%d %H.%M %Z') ||
      strptime(d, '%Y-%m-%d %H:%M %Z') ||
      strptime(d, '%Y-%m-%d %H:%M:%S %Z') ||
      strptime(t, '%Y-%m-%dT%H:%M:%S%z')

    if date.nil?
      #STDERR.puts "invalid date: #{d}"
      return
    end

    [date.to_time, msg[(t.length + 3)..-1]]
  rescue => e
    STDERR.puts day, msg
    raise e
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

class TextualParser
  def initialize line_parser, server_map
    @line_parser = line_parser
    @server_map = server_map
  end


  def parse base
    servers(base) do |server, path|
      dir_a(File.join(path, 'Channels')).each do |channel|
        raise channel unless channel.start_with? '#'

        days(File.join(path, 'Channels', channel)) do |day, msg|
          msg = @line_parser.parse_line day, msg
          next unless msg
          msg.server = server
          msg.channel = channel
          yield msg
        end
      end

      dir_a(File.join(path, 'Queries')).each do |nick|
        days(File.join(path, 'Queries', nick)) do |day, msg|
          msg = @line_parser.parse_line day, msg
          next unless msg
          msg.server = server
          msg.channel = nick
          yield msg
        end
      end

      days(File.join(path, 'Console')) do |day, msg|
        msg = @line_parser.parse_line day, msg
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
