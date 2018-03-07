require "spec"
require "http"
require "../src/hatty"

def create_request(method = "GET", resource = "/", headers = HTTP::Headers.new, body : String? = nil) : HTTP::Request
  HTTP::Request.new(method, resource, headers, body)
end

def create_response : HTTP::Server::Response
  io = IO::Memory.new
  HTTP::Server::Response.new(io)
end

def create_context(resource, method = "GET") : HTTP::Server::Context
  request = create_request(method, resource: resource,)
  response = create_response
  HTTP::Server::Context.new(request, response)
end