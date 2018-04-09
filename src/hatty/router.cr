module Hatty
  # :nodoc:
  module Router
    extend self

    class ExistingRoute < Exception
      def initialize(method, path)
        super("Existing route (#{method} #{path})")
      end

      def initialize(status)
        super("Existing route (status #{status})")
      end
    end

    class NotFoundError < Exception
      def initialize
        super("Not found")
      end
    end

    @@tree = Radix::Tree(String).new
    @@routes = Hash(String, Handler).new
    @@statuses = Hash(Int32, Handler).new
    @@global_status_handler : GlobalStatusHandler = ->(code : Int32, request : Request, response : Response) {
      html = Renderer.new(request, response).to_s
      response.send html
    }

    def add_route(method, path, handler)
      combined = combine method, path
      raise ExistingRoute.new(method, path) if @@routes[combined]?
      @@routes[combined] = handler
    end

    def add_route(status, handler)
      raise ExistingRoute.new(status) if @@statuses[status]?
      @@statuses[status] = handler
    end

    def global_status_handler
      @@global_status_handler
    end

    def global_status_handler=(handler)
      @@global_status_handler = handler
    end

    def tree
      @@tree
    end

    def get_handler(method, path)
      tree_path = @@tree.find path
      raise NotFoundError.new if !tree_path.found?

      combined = combine method, tree_path.payload
      raise NotFoundError.new if !@@routes[combined]?

      @@routes[combined]
    end

    # Adds the path to the Radix tree if it doesn't already exist
    def register(path)
      unless @@tree.find(path).found?
        @@tree.add path, path
      end
    end

    def send_status(status, request, response)
      # Use the custom status handler if set.
      if @@statuses[status]?
        response.status_code = status
        @@statuses[status].call request, response
      elsif @@global_status_handler
        response.status_code = status
        @@global_status_handler.not_nil!.call status, request, response
      else
        response.original.status_code = status
        response.original.print status
      end
    end

    private def combine(method, path)
      "#{method} #{path}"
    end

    # :nodoc:
    def i_want_to_clear_all_routes
      @@tree = Radix::Tree(String).new
      @@routes.clear
      @@statuses.clear
      @@global_status_handler = nil
    end

    module StatusTexts
      extend self

      def [](code)
        case code
        when 100
          "Continue"
        when 101
          "Switching Protocol"
        when 102
          "Processing"
        when 200
          "OK"
        when 201
          "Created"
        when 202
          "Accepted"
        when 203
          "Non-Authoritative Information"
        when 204
          "No Content"
        when 205
          "Reset Content"
        when 206
          "Partial Content"
        when 207..208
          "Multi-Status"
        when 226
          "IM Used"
        when 300
          "Multiple Choice"
        when 301
          "Moved permanently"
        when 302
          "Found"
        when 303
          "See Other"
        when 304
          "Not Modified"
        when 306
          "Unused"
        when 307
          "Temporary Redirect"
        when 308
          "Permanent Redirect"
        when 400
          "Bad Request"
        when 401
          "Unauthorized"
        when 402
          "Payment Required"
        when 403
          "Forbidden"
        when 404
          "Not Found"
        when 405
          "Method Not Allowed"
        when 406
          "Not Acceptable"
        when 407
          "Proxy Authentication Required"
        when 408
          "Request Timeout"
        when 409
          "Conflict"
        when 410
          "Gone"
        when 411
          "Length Required"
        when 412
          "Precondition Failed"
        when 413
          "Payload Too Large"
        when 414
          "URI Too Long"
        when 415
          "Unsupported Media Type"
        when 416
          "Requested Range Not Satisfiable"
        when 417
          "Expectation Failed"
        when 418
          "I'm a teapot"
        when 421
          "Misdirected Request"
        when 422
          "Unprocessable Entity"
        when 423
          "Locked"
        when 424
          "Failed Dependency"
        when 426
          "Upgrade Required"
        when 428
          "Precondition Required"
        when 429
          "Too Many Requests"
        when 431
          "Request Header Fields Too Large"
        when 451
          "Unavailable For Legal Reasons"
        when 500
          "Internal Server Error"
        when 501
          "Not Implemented"
        when 502
          "Bad Gateway"
        when 503
          "Service Unavailable"
        when 504
          "Gateway Timeout"
        when 505
          "HTTP Version Not Supported"
        when 506
          "Variant Also Negotiates"
        when 507
          "Insufficient Storage"
        when 508
          "Loop Detected"
        when 510
          "Not Extended"
        when 511
          "Network Authentication Required"
        end
      end
    end
  end
end
