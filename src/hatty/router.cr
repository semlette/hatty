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

    def add_route(method, path, handler)
      combined = combine method, path
      raise ExistingRoute.new(method, path) if @@routes[combined]?
      @@routes[combined] = handler
    end

    def add_route(status, handler)
      raise ExistingRoute.new(status) if @@statuses[status]?
      @@statuses[status] = handler
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
      else
        response.original.status_code = status
        response.original.print status
      end
    end

    private def combine(method, path)
      "#{method} #{path}"
    end
  end
end
