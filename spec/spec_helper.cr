require "spec"
require "http"
require "../src/hatty"

class Hatty::Testing::TestServer
  @@server = Hatty::Server.new(3000)

  def self.server
    @@server
  end

  def self.server=(@@server)
  end
end

# Override the Server#start method so it doesn't actually start the server.
class Hatty::Server
  def initialize(port)
    @server = HTTP::Server.new(port) { }
  end

  def start
  end
end

def create_request(method = "GET", resource = "/", headers = HTTP::Headers.new, body : String? = nil) : HTTP::Request
  HTTP::Request.new(method, resource, headers, body)
end

def create_response : HTTP::Server::Response
  io = IO::Memory.new
  HTTP::Server::Response.new(io)
end

def create_context(resource, method = "GET") : HTTP::Server::Context
  request = create_request(method, resource: resource)
  response = create_response
  HTTP::Server::Context.new(request, response)
end

def create_http_response(method = "GET", resource = "/", headers = HTTP::Headers.new, body : String? = nil) : HTTP::Client::Response
  request = create_request(method, resource, headers, body)
  io = IO::Memory.new
  response = HTTP::Server::Response.new(io)
  context = HTTP::Server::Context.new(request, response)
  Hatty::Testing::TestServer.server.handle_request(context)
  response.close
  io.rewind
  HTTP::Client::Response.from_io(io, decompress: false)
end

# Reset the router on each test
Spec.before_each do
  Hatty::Router.i_want_to_clear_all_routes
end
