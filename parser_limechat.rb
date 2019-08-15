require_relative 'message'

class LimeChatLineParser
  def parse_line day, msg
    date = strptime "#{day} #{msg[0..4]} CET", '%Y-%m-%d %H:%M %Z'
    return unless date
    date = date.to_time

    rest = msg[6..-1]
    m = rest.match /^([^\s]+?): (.*)$/
    if m.nil?
      Message.new date, nil, rest.strip
    else
      Message.new date, m[1], m[2].strip
    end
  end
end

class LimeChatParser
  def initialize line_parser, server_map
    @line_parser = line_parser
    @server_map = server_map
  end

  def parse base
    dir_a(base).each do |channel|
      if channel == 'Talk'
        dir_a(File.join(base, channel)).each do |log_name|
          m = log_name.match /(.+)_(\d{4}-\d\d-\d\d)_(.+)\.txt/
          unless m
            STDERR.puts "invalid log name: #{log_name}"
            return
          end
          nick = m[1]
          day = m[2]
          server_dir_name = m[3]

          File.open(File.join(base, channel, log_name), 'r') do |f|
            f.each_line do |line|
              msg = @line_parser.parse_line day, line
              unless msg
                STDERR.puts "#{day}: #{line}"
                next
              end
              msg.server = @server_map[server_dir_name]
              yield msg
            end
          end
        end

        next
      end

      dir_a(File.join(base, channel)).each do |log_name|
        m = log_name.match /(.+)_(.+)\.txt/
        unless m
          STDERR.puts "invalid log name: #{log_name}"
          return
        end
        day = m[1]
        server_dir_name = m[2]

        File.open(File.join(base, channel, log_name), 'r') do |f|
          f.each_line do |line|
            msg = @line_parser.parse_line day, line
            unless msg
              STDERR.puts "#{day}: #{line}"
              next
            end
            msg.server = @server_map[server_dir_name]
            msg.channel = channel
            yield msg
          end
        end
      end
    end
  end
end
