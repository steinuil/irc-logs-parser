require 'date'

class Message < Struct.new :time, :nick, :message, :channel, :server
  def self.csv_header
    ['server', 'channel', 'time', 'nick', 'message']
  end

  def to_csv
    [server, channel, time, nick, message]
  end
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
  SUSHIGIRL = 'irc.sushigirl.tokyo'
end
