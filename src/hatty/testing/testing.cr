require "http"
require "../../hatty"
require "./response"

# Helpers

private def create_request(method, resource, headers, body) : HTTP::Request
  HTTP::Request.new(method, resource, headers, body)
end

private def create_response : HTTP::Server::Response
  io = IO::Memory.new
  HTTP::Server::Response.new(io)
end

private def create_test_response(method, resource, headers, body) : Hatty::Testing::Response
  # Create request
  request = create_request(method, resource, headers, body)
  # Create response
  io = IO::Memory.new
  response = HTTP::Server::Response.new(io)
  # Create context and pass it to the server
  context = HTTP::Server::Context.new(request, response)
  handler = Hatty::Handlers::Routing.new
  handler.call(context)
  # Do some stuff I don't understand. But atleast the Kemal authors do.
  response.close
  io.rewind
  # Create the final response
  client_response = HTTP::Client::Response.from_io(io, decompress: false)
  Hatty::Testing::Response.new(client_response)
end

private class TestServer
  @@server = Hatty::Server.new(3000)

  def self.server
    @@server
  end

  def self.server=(@@server)
  end
end

# Override the Server#start method so it doesn't actually start the server.

class Hatty::Server
  def start
    TestServer.server = self
  end
end

# Create methods for testing the routes

# Sends a `GET` requests for *resource*.
# NOTE: Only available by importing `hatty/testing`.
# ```
# get "/" do |request, response|
#   response.send_status 401
# end
# response = get "/"
# response.status_code # -> 401
# ```
def get(resource, headers : HTTP::Headers? = nil, body : String? = nil) : Hatty::Testing::Response
  create_test_response("GET", resource, headers, body)
end

# Sends a `POST` requests for *resource*.
# NOTE: Only available by importing `hatty/testing`.
# ```
# post "/" do |request, response|
#   response.send_status 401
# end
# response = post "/"
# response.status_code # -> 401
# ```
def post(resource, headers : HTTP::Headers? = nil, body : String? = nil) : Hatty::Testing::Response
  create_test_response("POST", resource, headers, body)
end

# Sends a `DELETE` requests for *resource*.
# NOTE: Only available by importing `hatty/testing`.
# ```
# delete "/" do |request, response|
#   response.send_status 401
# end
# response = delete "/"
# response.status_code # -> 401
# ```
def delete(resource, headers : HTTP::Headers? = nil, body : String? = nil) : Hatty::Testing::Response
  create_test_response("DELETE", resource, headers, body)
end

# Sends a `PUT` requests for *resource*.
# NOTE: Only available by importing `hatty/testing`.
# ```
# put "/" do |request, response|
#   response.send_status 401
# end
# response = put "/"
# response.status_code # -> 401
# ```
def put(resource, headers : HTTP::Headers? = nil, body : String? = nil) : Hatty::Testing::Response
  create_test_response("PUT", resource, headers, body)
end

# Sends a `PATCH` requests for *resource*.
# NOTE: Only available by importing `hatty/testing`.
# ```
# patch "/" do |request, response|
#   response.send_status 401
# end
# response = patch "/"
# response.status_code # -> 401
# ```
def patch(resource, headers : HTTP::Headers? = nil, body : String? = nil) : Hatty::Testing::Response
  create_test_response("PATCH", resource, headers, body)
end
