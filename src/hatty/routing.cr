# Listen for `GET` requests on *path*.
#
# Example: Imaginary "get user" endpoint.
# ```
# get "/api/users/:id" do |request, response|
#   user = MyApi.get_user_by_id(request.params["id"])
#   response.send_json({ data: user })
# end
def get(path : String, &handler : Hatty::Handler)
  Hatty::Router.register path
  Hatty::Router.add_route("GET", path, handler)
end

# Listen for `POST` requests at *path*.
#
# Example: Imaginary "create user" endpoint.
# ```
# post "/api/users" do |request, response|
#   user = MyApi.create_user(request.body.user)
#   response.send_json({ data: user })
# end
def post(path : String, &handler : Hatty::Handler)
  Hatty::Router.register path
  Hatty::Router.add_route("POST", path, handler)
end

def put(path, &handler : Hatty::Handler)
  Hatty::Router.register path
  Hatty::Router.add_route("PUT", path, handler)
end

def delete(path, &handler : Hatty::Handler)
  Hatty::Router.register path
  Hatty::Router.add_route("DELETE", path, handler)
end

def patch(path, &handler : Hatty::Handler)
  Hatty::Router.register path
  Hatty::Router.add_route("PATCH", path, handler)
end

def status(code, &handler : Hatty::Handler)
  Hatty::Router.add_route(code, handler)
end

# This creates a "global status handler". This is like a status code handler,
# but receives all unhandled status codes.
# NOTE: This can only be used once.
#
# ```
# get "/unhandled" do |request, response|
#   response.send_status 410
# end
#
# status do |code, request, response|
#   response.send_text "Code: #{code}"
# end
#
# # GET /unhandled
# # > "Code: 410"
# ```
def status(&handler : Hatty::GlobalStatusHandler)
  Hatty::Router.global_status_handler = handler
end
