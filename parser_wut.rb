require_relative 'message'

class DotLogLineParser
  def parse_line year, msg
    date = strptime "#{year} #{msg[0..14]} CET", '%Y %b %d %H:%M:%S %Z'
    return unless date
    date = date.to_time

    rest = msg[16..-1]
    m = rest.match /^<(.+?)>(.*)$/
    if m.nil?
      Message.new date, nil, rest.strip
    else
      Message.new date, m[1], m[2].strip
    end
  end
end

class Old2Parser
  def initialize line_parser, dotlog_parser, server_map
    @line_parser = line_parser
    @dotlog_parser = dotlog_parser
    @server_map = server_map
  end

  def parse base
    servers(base) do |server, path, server_dir_name|
      dir_a(path).each do |channel|
        if File.directory?(File.join path, channel)
          days(File.join(path, channel)) do |day, line|
            msg = @line_parser.parse_line day, line
            unless msg
              STDERR.puts "#{day}: #{line}"
              next
            end
            msg.server = server
            msg.channel = channel unless channel == server_dir_name or channel == 'server'
            yield msg
          end
        elsif channel.end_with? '.txt'
          # this is just boring server logs like "Disconnected"
          next
        elsif channel.end_with? '.log'
          name = channel[0..-5]

          File.open(File.join(path, channel), 'r') do |f|
            f.each_line do |line|
              msg = @dotlog_parser.parse_line '2015', line
              unless msg
                STDERR.puts "#{channel}: #{line}"
                next
              end
              msg.server = server
              msg.channel = name
              yield msg
            end
          end
        else
          STDERR.puts File.join(path, channel)
        end
      end
    end
  end

  private

  def servers base
    dir_a(base).each do |dir|
      server = @server_map[dir]
      unless server
        STDERR.puts "invalid server: #{dir}"
        next
      end

      yield server, File.join(base, dir), dir
    end
  end

  def days path, &block
    dir_a(path).each do |f|
      single_file path, f, &block
    end
  end

  def single_file path, f
    if f.match /\d\d\.\d\d\.\d\d\.log/
      day = f[0..-5].gsub '.', '-'
    elsif not f.match /\d\d-\d\d-\d\d\.txt/
      STDERR.puts "invalid filename: #{f}"
      return
    else
      day = f[0..-5]
    end

    fname = File.join path, f

    File.open(fname, 'r') do |f|
      f.each_line do |line|
        yield day, line
      end
    end
  end
end
