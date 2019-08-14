require_relative 'message'

class OldMac
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

  def parse day, msg
    date, rest = parse_time day, msg
    return if date.nil?

    m = rest.match /^<(.+?)>(.*)$/

    if m.nil?
      Message.new date, nil, rest.strip
    else
      Message.new date, m[1], m[2].strip
    end
  end

  def stuff
    #channels = {}

    dir_a(@channels_dir).each do |channel|
      all = dir_a(File.join(@channels_dir, channel)).each.map do |file|
        day = file[0..-5]

        fname = File.join @channels_dir, channel, file
        next if fname.match /copia/

        f = File.read fname
        f.each_line.map do |line|
          parse day, line
        end.compact
      end.compact.reject(&:empty?).sort_by{ |x| x[0].time }

      puts all

      #channels[channel] = all
    end
  end

  def initialize channels_dir
    @channels_dir = channels_dir
  end
end

parser = OldMac.new '../ircdev/2013.08.25-2015.03.16/Rizon/Channels'

p parser.stuff
