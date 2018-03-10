require "http/client"

class Hatty::Testing::Response
  def initialize(@request : HTTP::Client::Response)
  end

  def status_code
    @request.status_code
  end

  def headers
    @request.headers
  end

  def body
    @request.body
  end

  def json? : Bool
    @request.headers["Content-Type"]? == "application/json"
  end
end