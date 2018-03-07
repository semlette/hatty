module Hatty
  class Request
    @params = {} of String => String
    @parsed_params = false
    @query = {} of String => String
    @parsed_query = false

    def initialize(@request : HTTP::Request)
    end

    # Returns the original request
    def original : HTTP::Request
      @request
    end

    def method
      @request.method
    end

    def body
      # body.to_json
    end

    def body(mappings)
      # mappings.from_json(json)
    end

    def body(builder : JSON::Builder)
    end

    private def parse_as_json(body)
    end

    private def parse_as_mapped_json(body)
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

    def params : Hash(String, String)
      if @parsed_params
        @params
      else
        tree_path = Router.tree.find @request.path
        @parsed_params = true
        @params = tree_path.params
      end
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
