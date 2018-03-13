require "http/client"

class Hatty::Testing::Response
  def initialize(@request : HTTP::Client::Response)
  end

  def original : HTTP::Client::Response
    @request
  end

  def status_code
    @request.status_code
  end

  def headers
    @request.headers
  end

  def body : String
    @request.body
  end

  def json : JSON::Any?
    if json?
      JSON.parse body
    end
  end

  def json(mappings)
    if json?
      mappings.from_json body
    end
  end

  def json? : Bool
    @request.headers["Content-Type"]? == "application/json"
  end
end
