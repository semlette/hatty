module Hatty
  class Request
    @params : Hash(String, String)? = nil

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

    def params : Hash(String, String)
      if @params
        @params.as(Hash(String, String))
      else
        tree_path = Router.tree.find @request.path
        @params = tree_path.params
        @params.as(Hash(String, String))
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
