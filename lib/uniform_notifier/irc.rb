module UniformNotifier
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
      @stay_connected = irc_information[:stay_connected].nil? ? true : irc_information[:stay_connected]

      connect if @stay_connected
    rescue LoadError
      @irc = nil
      raise NotificationError.new( 'You must install the cinch gem to use irc notification: `gem install cinch`' )
    end

    private
    def self.connect
      @irc = bot = Cinch::Bot.new do
        configure do |c|
          c.nick            = @nick
          c.server          = @server
          c.channels        = @channels
          c.verbose         = true
        end
      end

      @irc.start
    end

    def self.notify( message )
      connect unless @stay_connected
      bot.msg(message)
    end

  end
end
