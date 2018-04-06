module Hatty
  class Request
    @params = {} of String => String
    @parsed_params = false
    @query = {} of String => String
    @parsed_query = false
    @body : JSON::Any? = nil
    @parsed_body = false
    @form = {} of String => String
    @parsed_form = false
    @files = {} of String => Tempfile
    @parsed_files = false

    def initialize(@request : HTTP::Request)
    end

    # Returns the original request
    def original : HTTP::Request
      @request
    end

    def method
      @request.method
    end

    def cookies : HTTP::Cookies
      @request.cookies
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

    def form : Hash(String, String)?
      content_type = @request.headers["Content-Type"]?
      is_formdata = content_type && content_type.starts_with?("multipart/form-data")
      if !@parsed_form && @request.body && is_formdata
        parse_form
        @form
      elsif @parsed_form
        @form
      else
        nil
      end
    end

    def files : Hash(String, Tempfile)?
      content_type = @request.headers["Content-Type"]?
      is_formdata = content_type && content_type.starts_with?("multipart/form-data")
      if !@parsed_files && @request.body && is_formdata
        parse_files
        @files
      elsif @parsed_files
        @files
      else
        nil
      end
    end

    private def parse_form
      HTTP::FormData.parse(@request) do |part|
        next unless part
        filename = part.filename
        next if filename
        @form[part.name] = part.body.gets_to_end
      end
      @parsed_form = true
    end

    private def parse_files
      HTTP::FormData.parse(@request) do |part|
        next unless part
        filename = part.filename
        next unless filename
        @files[part.name] = Tempfile.open filename.not_nil! do |file|
          IO.copy(part.body, file)
        end
      end
      @parsed_files = true
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
