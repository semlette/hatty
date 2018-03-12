module Hatty
  # Basically `HTTP::Server` but with routing.
  class Server
    @server : HTTP::Server
    @handlers : Array(HTTP::Handler)

    def initialize(port : Int32)
      @handlers = [] of HTTP::Handler
      @handlers << HTTP::LogHandler.new unless Hatty.config.disable_logging
      @handlers << Handlers::Routing.new
      @server = HTTP::Server.new port, handlers
    end

    def native
      @server
    end

    def handlers
      @handlers
    end

    # Starts Hatty.
    def start
      @server.listen
    end

    def stop
      @server.close
    end
  end

  # Starts Hatty.
  # This is a "shortcut" for running
  # ```
  # server = Hatty::Server.new(port: 3000)
  # server.start
  # ```
  def self.start(port = 3000)
    server = Server.new(port)
    server.start

    server
  end
end
