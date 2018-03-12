require "logger"

module Hatty::Handlers
  class Logging
    include HTTP::Handler
    @@logger = Logger.new(STDOUT)

    def call(context)
      unless Hatty.config.disable_logging
        path = context.request.path
        method = context.request.method
        @@logger.info "#{method} #{path}"
      end

      call_next(context)
    end
  end
end
