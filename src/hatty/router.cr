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
    @@global_status_handler : GlobalStatusHandler? = nil

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
      raise ExistingRoute.new "global" if !@@global_status_handler.nil?
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
  end
end
