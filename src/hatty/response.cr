module Hatty
  class Response
    def initialize(@response : HTTP::Server::Response)
      @sent = false
      @status_code = 200
      @hatty_send_status_code = false
      @response.headers.add "X-Powered-By", "Hatty" unless Hatty.config.disable_powered_by
    end

    # Returns the original response
    def original : HTTP::Server::Response
      @response
    end

    def status_code
      @status_code
    end

    def status_code=(code)
      @status_code = code
      @response.status_code = code
    end

    def headers : HTTP::Headers
      @response.headers
    end

    def cookies : HTTP::Cookies
      @response.cookies
    end

    # Sends the *response* "as-is" to the client.
    # ```
    # get "/" do |request, response|
    #   response.send "Hellooo!"
    # end
    # ```
    def send(response) : Nil
      raise ExhaustedError.new if @sent
      @response.print response
      @sent = true
    end

    # Sends the *response* as `application/json` to the client.
    # NOTE: The *response* must have a `#to_json` method. Hatty automatically requires the JSON module which adds such method to `Hash`, `NamedTuple` and others.
    # ```
    # get "/" do |request, response|
    #   json = {hello: "world"}
    #   response.send_json(json)
    # end
    # ```
    # The client receives
    # ```json
    # {"hello": "world"}
    # ```
    def send_json(json jsonable) : Nil
      @response.content_type = "application/json"
      send jsonable.to_json
    end

    # Sends the *response* as `application/json` to the client.
    def send_json(json : String) : Nil
      @response.content_type = "application/json"
      send json
    end

    # Sends the *text* as `text/plain` to the client.
    # ```
    # get "/" do |request, response|
    #   response.send_text "FeelsGoodMan"
    # end
    # ```
    # The client receives
    # ```text
    # FeelsGoodMan
    # ```
    def send_text(text) : Nil
      @response.content_type = "text/plain"
      send text
    end

    # Forwards the request to the status handlers.
    #
    # Example: Imaginary admin page with authorization
    # ```
    # get "/admin" do |request, response|
    #   authorized = MyApi.valid_token?(request.headers["Authorization"]?)
    #   if !authorized
    #     response.send_status 401
    #     next
    #   end
    #   # ...
    # end
    #
    # # `Response#send_status 401` forwards the request to this handler
    # status 401 do |request, response|
    #   response.send_text "ERR! Unauthorized."
    # end
    # ```
    #
    def send_status(@status_code) : Nil
      # Raise if something has already been sent
      raise ExhaustedError.new if @sent
      # Raise if `#send_status` has already been called
      raise ExhaustedError.new if @hatty_send_status_code
      @hatty_send_status_code = true
    end

    # Redirects to *location*.
    # ```
    # get "/article/:id" do |request, response|
    #   response.redirect("/new-article-url/#{request.params["id"]}")
    # end
    # ```
    def redirect(to location : String) : Nil
      # Raise if something has already been sent
      raise ExhaustedError.new if @sent
      @status_code = 301
      @response.headers["Location"] = location
      @sent = true
    end

    def send_file(path : String, filename : String? = nil) : Nil
      file = File.open(path)
      send_file(file, filename)
    end

    def send_file(file : File, filename : String? = nil) : Nil
      raise ExhaustedError.new if @sent
      header = "attachment"
      header += "; filename=\"#{filename}\"" unless !filename
      @response.headers["Content-Disposition"] = header
      send file.gets_to_end
    end

    # NOTE: INTERNAL PROPERTY.
    # This property tells Hatty if it should forward the request
    # to a status handler.
    def hatty_send_status_code : Bool
      @hatty_send_status_code
    end

    # NOTE: INTERNAL PROPERTY.
    # This property tells Hatty if the response has been used.
    def hatty_sent : Bool
      @sent
    end

    class ExhaustedError < Exception
      def initialize
        super("Trying to send a response that has already sent")
      end
    end
  end
end
