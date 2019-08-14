require 'date'

Message = Struct.new :time, :nick, :message, :channel, :server

def dir_a dir
  Dir.entries(dir).-(['.', '..']) rescue []
end

def strptime date, fmt
  DateTime.strptime(date, fmt) rescue nil
end

module Networks
  RIZON = 'irc.rizon.net'
  WHAT_NETWORK = 'irc.what-network.net'
  FREENODE = 'chat.freenode.net'
  ANIMEBYTES = 'irc.animebytes.tv'
  IRCHIGHWAY = 'irc.irchighway.net'
  INSTALLGENTOO = 'irc.installgentoo.com'
  ESPER = 'irc.esper.net'
  QUAKENET = 'irc.quakenet.org'
  TWITCH = 'irc.twitch.tv'
  UNDERNET = 'irc.undernet.org'
  USTREAM = 'chat1.ustream.tv'
end
