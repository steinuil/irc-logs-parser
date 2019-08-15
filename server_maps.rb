require_relative 'message'

module ServerMaps
  OLDER_MAC = {
    '_g_' => Networks::INSTALLGENTOO,
    'animebytes' => Networks::ANIMEBYTES,
    'chat.freenode.net' => Networks::FREENODE,
    'IRCHighway' => Networks::IRCHIGHWAY,
    'QuakeNet' => Networks::QUAKENET,
    'Rizon' => Networks::RIZON,
    'Twitch' => Networks::TWITCH,
    'What-Network.Net' => Networks::WHAT_NETWORK,
    'Animebytes (EA118)' => Networks::ANIMEBYTES,
    'Esper (B523A)' => Networks::ESPER,
    'freenode (4F6A2)' => Networks::FREENODE,
    'IRCHW (AC5CE)' => Networks::IRCHIGHWAY,
    'Rizon (FB91E)' => Networks::RIZON,
    'Undernet (4DE50)' => Networks::UNDERNET,
    'Ustream (2016C)' => Networks::USTREAM,
  }

  OLD_WINDOWS = {
    'AnimeBytes' => Networks::ANIMEBYTES,
    'IRCHighWay' => Networks::IRCHIGHWAY,
    'Rizon' => Networks::RIZON,
    'Twitch' => Networks::TWITCH,
    'ustream' => Networks::USTREAM,
  }

  OLD_MAC = {
    'chat1.ustream.tv (65734)' => Networks::USTREAM,
    'chat1.ustream.tv (95872)' => Networks::USTREAM,
    'Freenode (84A38)' => Networks::FREENODE,
    'Highway (1A734)' => Networks::IRCHIGHWAY,
    'Rizon (2B319)' => Networks::RIZON,
    'Sushigirl (E9C92)' => Networks::SUSHIGIRL,
    'Ustream (65976)' => Networks::USTREAM,
    'Ustream (95872)' => Networks::USTREAM,
  }

  LIMECHAT = {
    'Freenode' => Networks::FREENODE,
    'irc.rizon.net' => Networks::RIZON,
  }
end
