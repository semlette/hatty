module Hatty
  class Renderer
    def initialize(@request : Request, @response : Response)
    end

    ECR.def_to_s("./src/hatty/global-status-handler.ecr")
  end
end
