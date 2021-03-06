module Hatty::Handlers
  class Routing
    include HTTP::Handler

    def call(context)
      unless context.request.version.includes?("HTTP")
        call_next(context)
        return
      end

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
        # If `#hatty_send_status_code` is true, the user has called `#send_status`
        # and the request should be forwarded to the status handlers.
        if response.hatty_send_status_code
          Router.send_status(response.status_code, request, response)
        end
      rescue error : Router::NotFoundError
        Router.send_status(404, request, response)
      rescue error
        Router.send_status(500, request, response) # Send the status before we re-raise
        context.response.close                     # Make sure to close the response
        raise error                                # Raise the error to the user
      end
    end
  end
end
