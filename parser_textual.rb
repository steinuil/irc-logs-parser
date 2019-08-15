require_relative 'message'

class TextualParser
  def initialize line_parser, server_map
    @line_parser = line_parser
    @server_map = server_map
  end

  def parse base
    servers(base) do |server, path|
      dir_a(File.join(path, 'Channels')).each do |channel|
        raise channel unless channel.start_with? '#'

        days(File.join(path, 'Channels', channel)) do |day, line|
          msg = @line_parser.parse_line day, line
          unless msg
            STDERR.puts "#{day}: #{line}"
            next
          end
          msg.server = server
          msg.channel = channel
          yield msg
        end
      end

      dir_a(File.join(path, 'Queries')).each do |nick|
        days(File.join(path, 'Queries', nick)) do |day, line|
          msg = @line_parser.parse_line day, line
          unless msg
            STDERR.puts "#{day}: #{line}"
            next
          end
          msg.server = server
          msg.channel = nick
          yield msg
        end
      end

      days(File.join(path, 'Console')) do |day, line|
        msg = @line_parser.parse_line day, line
        unless msg
          STDERR.puts "#{day}: #{line}"
          next
        end
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
