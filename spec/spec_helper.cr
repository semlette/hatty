require "spec"
require "http"
require "../src/hatty"

def create_request(method = "GET", resource = "/") : HTTP::Request
  HTTP::Request.new(method, resource)
end

def create_response : HTTP::Server::Response
  io = IO::Memory.new
  HTTP::Server::Response.new(io)
end

def create_context(resource) : HTTP::Server::Context
  request = create_request(resource: resource)
  response = create_response
  HTTP::Server::Context.new(request, response)
end