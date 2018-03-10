require "./spec_helper"
require "../src/hatty/testing"

private class JSONMapping
  JSON.mapping({
    hello: String
  })
end

describe "Testing" do
  describe "Response" do
    describe "#original" do
      it "returns the original HTTP::Client::Response" do
        http_response = create_http_response("GET", "/")
        response = Hatty::Testing::Response.new(http_response)
        response.original.should be_a HTTP::Client::Response
      end
    end
    
    describe "#status_code" do
      it "returns the status code" do
        get "/testing-response-status-code" do |request, response|
          response.send_status 201
        end

        http_response = create_http_response("GET", "/testing-response-status-code")
        response = Hatty::Testing::Response.new(http_response)
        response.status_code.should eq 201

        second_http_response = create_http_response("GET", "/i-dont-exist")
        second_response = Hatty::Testing::Response.new(second_http_response)
        second_response.status_code.should eq 404
      end
    end
    
    describe "#body" do
      it "returns the response body" do
        json = {
          "hatty" => {
            "awesome" => true,
            "easy"    => true,
          },
        }
        get "/testing-response" do |request, response|
          response.send_json(json)
        end

        http_response = create_http_response("GET", "/testing-response")
        response = Hatty::Testing::Response.new(http_response)
        response.body.should eq json.to_json
      end
    end

    describe "#json" do
      it "returns the body as JSON" do
        get "/json" do |request, response|
          response.send_json({"hello" => "world"})
        end

        http_response = create_http_response("GET", "/json")
        response = Hatty::Testing::Response.new(http_response)
        response.json.should be_a JSON::Any
      end

      it "returns nil if the body is not JSON" do
        get "/not_json" do |request, response|
          response.send_text "I AM NOT JSON"
        end

        http_response = create_http_response("GET", "/not_json")
        response = Hatty::Testing::Response.new(http_response)
        response.json.should eq nil
      end
    end

    describe "#json(mappings)" do
      it "maps the body" do
        get "/json" do |request, response|
          response.send_json({"hello" => "world"})
        end

        http_response = create_http_response("GET", "/json")
        response = Hatty::Testing::Response.new(http_response)
        json = response.json(JSONMapping).not_nil!
        json.should be_a JSONMapping
        json.hello.should eq "world"
      end

      it "returns nil if the body is not JSON" do
        get "/not_json" do |request, response|
          response.send_text "I AM NOT JSON"
        end

        http_response = create_http_response("GET", "/not_json")
        response = Hatty::Testing::Response.new(http_response)
        json = response.json(JSONMapping)
        json.should be nil
      end
    end

    describe "#json?" do
      it "returns true if the body is JSON" do
        get "/json" do |request, response|
          response.send_json({"hello" => "world"})
        end

        http_response = create_http_response("GET", "/json")
        response = Hatty::Testing::Response.new(http_response)
        response.json?.should be_true
      end

      it "returns false if the body is *not* JSON" do
        get "/not_json" do |request, response|
          response.send_text "HALLOOO"
        end

        http_response = create_http_response("GET", "/not_json")
        response = Hatty::Testing::Response.new(http_response)
        response.json?.should be_false
      end
    end
    
  end

  describe "get" do
    it "returns a Hatty::Testing::Response" do
      get "/testing-fake-get" do
      end

      response = get "/testing-fake-get"
      response.should be_a Hatty::Testing::Response
      response.status_code.should eq 200
    end
  end
  
  describe "post" do
    it "returns a Hatty::Testing::Response" do
      post "/testing-fake-post" do
      end
      
      response = post "/testing-fake-post"
      response.should be_a Hatty::Testing::Response
      response.status_code.should eq 200
    end
  end

  describe "put" do
    it "returns a Hatty::Testing::Response" do
      put "/testing-fake-put" do
      end

      response = put "/testing-fake-put"
      response.should be_a Hatty::Testing::Response
      response.status_code.should eq 200
    end
  end

  describe "delete" do
    it "returns a Hatty::Testing::Response" do
      delete "/testing-fake-delete" do
      end

      response = delete "/testing-fake-delete"
      response.should be_a Hatty::Testing::Response
      response.status_code.should eq 200
    end
  end

  describe "patch" do
    it "returns a Hatty::Testing::Response" do
      patch "/testing-fake-patch" do
      end

      response = patch "/testing-fake-patch"
      response.should be_a Hatty::Testing::Response
      response.status_code.should eq 200
    end
  end
end
