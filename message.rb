require 'date'

Message = Struct.new :time, :nick, :message

def dir_a dir
  Dir.entries(dir) - ['.', '..']
end

def strptime date, fmt
  DateTime.strptime(date, fmt) rescue nil
end

