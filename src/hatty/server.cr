module Hatty
  class Server
    @server : HTTP::Server

    def initialize(port)
      @server = HTTP::Server.new port do |context|
        handle_request context
      end
    end

    def native
      @server
    end

    # Starts Hatty.
    def start
      @server.listen
    end

    def stop
      @server.close
    end

    # NOTE: INTERNAL METHOD
    def handle_request(context)
      path = context.request.path
      method = context.request.method

      # Create custom requests & responses
      request = Request.new(context.request)
      response = Response.new(context.response)

      begin
        # Get the handler for the path.
        # This raises a `Router::NotFoundError` if there
        # is no handler for the path.
        handler = Router.get_handler(method, path)
        handler.call request, response
        # If `#hatty_send_status_code` is true, the user has called` #send_status`
        # and the request should be forwarded to the status handlers.
        if response.hatty_send_status_code
          Router.send_status(response.status_code, request, response)
        end
      rescue error : Router::NotFoundError
        Router.send_status(404, request, response)
      rescue error
        Router.send_status(500, request, response) # Send the status before we re-raise
        context.response.close # Make sure to close the response
        raise error # Raise the error to the user
      end
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
