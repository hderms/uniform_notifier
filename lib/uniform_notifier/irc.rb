module UniformNotifier
  attr_accessor :irc, :nick, :server, :channels
  class IRC < Base
    @receiver = nil
    @irc = nil
    @password = nil

    def self.active?
      @irc
    end

    def self.out_of_channel_notify( message )
      return unless active?
      notify( message )
    end

    def self.setup_connection( irc_information )
      return unless irc_information

      require 'cinch'

      @irc = irc_information
      @server = irc_information[:server]
      @channels = irc_information[:channels]
      @nick = irc_information[:nick]
      @password = irc_information[:password]

      connect 
    rescue LoadError
      @irc = nil
      raise NotificationError.new( 'You must install the cinch gem to use irc notification: `gem install cinch`' )
    end

    private
    def self.connect
      @irc =  Cinch::Bot.new
      @irc.config.nick            = @nick
      @irc.config.server          = @server
      @irc.config.channels        = @channels
      @irc.config.verbose         = false

      Thread.new {
        @irc.start
      }
    end

    def self.notify( message )
      connect unless @irc
      @channels.each do |chann|
      @irc.Channel(chann).msg(message)
      end
    end

  end
end
