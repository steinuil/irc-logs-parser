require_relative 'message'

class BaseLogParser
  def messages_in file, time_info
    File.open(file, 'r') do |f|
      f.each_line do |line|
        msg = @line_parser.parse_line time_info, line
        if msg
          yield msg
        else
          STDERR.puts "#{file}: #{line}"
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

class TextualLogParser < BaseLogParser
  def initialize line_parser, server_map
    @line_parser = line_parser
    @server_map = server_map
  end

  def parse base
    entries_in base do |server_dir|
      next if server_dir == 'temp'
      server = @server_map[server_dir] || raise(server_dir)
      path = File.join base, server_dir

      entries_in File.join(path, 'Channels') do |channel|
        entries_in File.join(path, 'Channels', channel) do |log_name|
          next if log_name.match /copia/
          day = log_name[0..-5]

          messages_in File.join(path, 'Channels', channel, log_name), day do |msg|
            msg.server = server
            msg.channel = channel
            yield msg
          end
        end
      end

      entries_in File.join(path, 'Queries') do |nick|
        entries_in File.join(path, 'Queries', nick) do |log_name|
          next if log_name.match /copia/
          day = log_name[0..-5]

          messages_in File.join(path, 'Queries', nick, log_name), day do |msg|
            msg.server = server
            msg.channel = nick
            yield msg
          end
        end
      end

      # skip Console dir
    end
  end
end

class HexchatOldLogParser < BaseLogParser
  def initialize line_parser, dotlog_parser, server_map
    @line_parser = line_parser
    @dotlog_parser = dotlog_parser
    @server_map = server_map
  end

  def parse base
    entries_in base do |server_dir|
      next if server_dir == 'NETWORK'
      server = @server_map[server_dir] || raise(server_dir)

      directories_in File.join(base, server_dir) do |channel|
        next if channel == 'server' || channel == server_dir
        path = File.join base, server_dir, channel

        entries_in path do |log_name|
          day = log_name[0..-5]

          messages_in File.join(path, log_name), day do |msg|
            msg.server = server
            msg.channel = channel
            yield msg
          end
        end
      end

      files_in File.join(base, server_dir) do |log_name|
        next unless log_name.end_with? '.log'
        path = File.join base, server_dir, log_name
        nick = log_name[0..-5]
        next if nick == 'server' || nick == server_dir

        messages_in_dotlog path, '2015' do |msg|
          msg.server = server
          msg.channel = nick
          yield msg
        end
      end
    end
  end

  def directories_in path
    entries_in(path) { |entry| yield entry if File.directory? File.join(path, entry) }
  end

  def files_in path
    entries_in(path) { |entry| yield entry unless File.directory? File.join(path, entry) }
  end

  def messages_in_dotlog file, year
    File.open file, 'r' do |f|
      f.each_line do |line|
        msg = @dotlog_parser.parse_line year, line
        if msg
          yield msg
        else
          STDERR.puts "#{file}: #{line}"
          next
        end
      end
    end
  end
end

class HexchatNewLogParser < BaseLogParser
  def initialize line_parser, server_map
    @line_parser = line_parser
    @server_map = server_map
  end

  def parse base
    entries_in base do |server_dir|
      next if server_dir == 'NETWORK'
      server = @server_map[server_dir] || raise(server_dir)

      entries_in File.join(base, server_dir) do |channel|
        next if channel == 'server' || channel == server_dir
        path = File.join base, server_dir, channel
        next unless File.directory? path

        entries_in path do |log_name|
          day = log_name[0..-5]

          messages_in File.join(path, log_name), day do |msg|
            msg.server = server
            msg.channel = channel
            yield msg
          end
        end
      end
    end
  end
end

class HexchatThinkpadLogParser < BaseLogParser
  def initialize line_parser, server_map
    @line_parser = line_parser
    @server_map = server_map
  end

  def parse base
    entries_in base do |server_dir|
      next if server_dir == 'NETWORK'
      server = @server_map[server_dir] || raise(server_dir)

      entries_in File.join(base, server_dir) do |channel|
        next if channel == 'server' || channel == server_dir
        path = File.join base, server_dir, channel
        next unless File.directory? path

        entries_in path do |log_name|
          year = log_name[0..3]

          messages_in File.join(path, log_name), year do |msg|
            msg.server = server
            msg.channel = channel
            yield msg
          end
        end
      end
    end
  end
end
