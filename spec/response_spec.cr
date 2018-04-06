require "./spec_helper"

describe Hatty::Response do
  context "`Hatty.config.disable_powered_by` is disabled" do
    it "adds `X-Powered-By` header" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.headers["X-Powered-By"]?.should eq "Hatty"
    end
  end

  context "`Hatty.config.disable_powered_by` is enabled" do
    it "doesn't add `X-Powered-By` header" do
      Hatty.config.disable_powered_by = true
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.headers["X-Powered-By"]?.should be_falsey
    end
  end

  describe "#original" do
    it "returns the original `HTTP::Server::Response`" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.original.should be http_response
    end
  end

  describe "#status_code" do
    it "is 200 by default" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.status_code.should eq 200
    end

    it "returns the status code" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.status_code.should eq http_response.status_code
    end
  end

  describe "#status_code=" do
    it "sets the status code" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.status_code = 404 # Set the status code

      response.status_code.should eq 404
      http_response.status_code.should eq 404
    end
  end

  describe "#headers" do
    it "returns `HTTP::Headers`" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.headers.should be_a HTTP::Headers
    end

    it "returns the response' headers" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.headers.should be http_response.headers
    end
  end

  describe "#cookies" do
    it "returns a `#original#cookies`" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.cookies.should be response.original.cookies
    end
  end

  describe "#send" do
    # TODO: Test if the response is actually being sent

    it "raises if called more than once" do
      expect_raises Hatty::Response::ExhaustedError do
        http_response = create_response
        response = Hatty::Response.new(http_response)
        response.send "One"
        response.send "Two"
      end
    end

    it "sets `@sent` to true" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send "123"
      response.hatty_sent.should be_true
    end

    it "returns nil" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send("123").should eq nil
    end
  end

  describe "#send_json" do
    # TODO: Test if the response is actually being sent

    it "raises if called more than once" do
      expect_raises Hatty::Response::ExhaustedError do
        http_response = create_response
        response = Hatty::Response.new(http_response)
        response.send_json({"times" => 1})
        response.send_json({"times" => 2})
      end
    end

    it "sets the content type to `application/json`" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_json({"abc" => 123})
      response.headers["Content-Type"].should eq "application/json"
    end

    it "sets `@sent` to true" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_json({"abc" => 123})
      response.hatty_sent.should be_true
    end

    it "returns nil" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_json({"abc" => 123}).should eq nil
    end
  end

  describe "#send_json(json : String)" do
    # TODO: Test if the response is actually being sent

    it "raises if called more than once" do
      expect_raises Hatty::Response::ExhaustedError do
        http_response = create_response
        response = Hatty::Response.new(http_response)
        response.send_json({"times" => 1}.to_json)
        response.send_json({"times" => 2}.to_json)
      end
    end

    it "sets the content type to `application/json`" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_json({"abc" => 123}.to_json)
      response.headers["Content-Type"].should eq "application/json"
    end

    it "sets `@sent` to true" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_json({"abc" => 123}.to_json)
      response.hatty_sent.should be_true
    end

    it "returns nil" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_json({"abc" => 123}.to_json).should eq nil
    end
  end

  describe "#send_text" do
    # TODO: Test if the response is actually being sent

    it "raises if called more than once" do
      expect_raises Hatty::Response::ExhaustedError do
        http_response = create_response
        response = Hatty::Response.new(http_response)
        response.send_text "One"
        response.send_text "Two"
      end
    end

    it "sets the content type to `text/plain`" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_text "Testing testing 123"
      response.headers["Content-Type"].should eq "text/plain"
    end

    it "sets `@sent` to true" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_text "Testing testing 123"
      response.hatty_sent.should be_true
    end

    it "returns nil" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_text("Testing testing 123").should eq nil
    end
  end

  describe "#send_status" do
    it "raises if called more than once" do
      expect_raises Hatty::Response::ExhaustedError do
        http_response = create_response
        response = Hatty::Response.new(http_response)
        response.send_status 404
        response.send_status 404
      end
    end

    it "sets `@hatty_send_status_code` to true" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_status 400
      response.hatty_send_status_code.should be_true
    end

    it "returns nil" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.send_status(400).should eq nil
    end
  end

  describe "#redirect" do
    it "sets the status code to `301`" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.redirect("/test")
      response.status_code.should eq 301
    end

    it "sets the location header" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.redirect("/test")
      response.headers["Location"]?.should eq "/test"
    end

    it "raises if called more than once" do
      expect_raises Hatty::Response::ExhaustedError do
        http_response = create_response
        response = Hatty::Response.new(http_response)
        response.redirect("/abc")
        response.redirect("/def")
      end
    end

    it "sets `#hatty_sent` to true" do
    http_response = create_response
    response = Hatty::Response.new(http_response)
    response.redirect("/test")
    response.hatty_sent.should eq true
    end

    it "returns nil" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.redirect("/test").should eq nil
    end
  end
  
  describe "#hatty_send_status_code" do
    it "returns a boolean" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.hatty_send_status_code.should be_a Bool
    end
  end

  describe "#hatty_sent" do
    it "returns a boolean" do
      http_response = create_response
      response = Hatty::Response.new(http_response)
      response.hatty_sent.should be_a Bool
    end
  end

end
