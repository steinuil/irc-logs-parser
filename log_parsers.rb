require_relative 'message'

class BaseLogParser
  def messages_in file, time_info
    File.open(file, 'r') do |f|
      f.each_line do |line|
        msg = @line_parser.parse_line time_info, line
        if msg
          yield msg
        else
          STDERR.puts "#{day}: #{line}"
          next
        end
      end
    end
  end

  def entries_in dir
    entries = Dir.entries(dir) rescue return
    entries.-(['.', '..']).each { |entry| yield entry }
  end
end

class LimechatLogParser < BaseLogParser
  def initialize line_parser, server_map
    @line_parser = line_parser
    @server_map = server_map
  end

  def parse base
    entries_in base do |channel_dir|
      entries_in File.join(base, channel_dir) do |log_name|
        channel_name, day, server_dir_name =
          (channel_dir == 'Talk') ?  dm_log(log_name) : channel_log(channel_dir, log_name)

        messages_in File.join(base, channel_dir, log_name), day do |msg|
          msg.server = @server_map[server_dir_name] || raise(server_dir_name)
          msg.channel = channel_name
          yield msg
        end
      end
    end
  end

  def dm_log log_name
    m = log_name.match(/(.+)_(\d{4}-\d\d-\d\d)_(.+)\.txt/) || raise(log_name)
    nick = m[1] || raise
    day = m[2] || raise
    server_dir_name = m[3] || raise

    [nick, day, server_dir_name]
  end

  def channel_log channel, log_name
    m = log_name.match(/(\d{4}-\d\d-\d\d)_(.+)\.txt/) || raise(log_name)
    day = m[1] || raise
    server_dir_name = m[2] || raise

    [channel, day, server_dir_name]
  end
end