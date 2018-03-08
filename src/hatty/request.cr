module Hatty
  class Request
    @params = {} of String => String
    @parsed_params = false
    @query = {} of String => String
    @parsed_query = false
    @body : JSON::Any? = nil
    @parsed_body = false

    def initialize(@request : HTTP::Request)
    end

    # Returns the original request
    def original : HTTP::Request
      @request
    end

    def method
      @request.method
    end

    def body : JSON::Any?
      is_json = @request.headers["Content-Type"]? === "application/json"
      if !@parsed_body && @request.body && is_json
        @parsed_body = true
        @body = JSON.parse @request.body.not_nil!
      elsif @parsed_body
        @body
      end
    end

    def body(mappings)
      is_json = @request.headers["Content-Type"]? === "application/json"
      if @request.body && is_json
        mappings.from_json(@request.body.not_nil!)
      end
    end

    def query : Hash(String, String)
      if !@parsed_query && @request.query
        params = HTTP::Params.parse @request.query.not_nil!
        params.each do |key, value|
          @query[key] = value
        end
      end

      @query
    end

    # Returns a hash with the url parameters.
    # ```
    # get "/users/:id" do |request, response|
    #   puts response.params["id"]
    # end
    #
    # # GET /users/3
    # # > "3"
    # ```
    def params : Hash(String, String)
      if !@parsed_params
        tree_path = Router.tree.find @request.path
        @params = tree_path.params
      end

      @params
    end

    # Alias for `#params`
    def parameters : Hash(String, String)
      params
    end

    def path
      @request.path
    end

    # Alias for `#path`
    def url
      path
    end
  end
end
