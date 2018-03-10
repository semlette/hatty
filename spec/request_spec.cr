require "./spec_helper"

private class TestMapping
  JSON.mapping({
    hello: String,
  })
end

describe Hatty::Request do
  describe "#original" do
    it "returns the original `HTTP::Request`" do
      http_request = create_request
      request = Hatty::Request.new(http_request)
      request.original.should be http_request
    end
  end

  describe "#method" do
    it "returns the method" do
      get_request = create_request method: "GET"
      Hatty::Request.new(get_request).method.should eq "GET"

      post_request = create_request method: "POST"
      Hatty::Request.new(post_request).method.should eq "POST"
    end
  end

  describe "#body" do
    it "returns nil if there is no body" do
      post_request = create_request method: "POST"
      Hatty::Request.new(post_request).body.should eq nil
    end

    it "returns nil if the `Content-Type` is not `application/json`" do
      headers = HTTP::Headers{"Content-Type" => "text/plain"}
      body = {"hello" => "world"}
      post_request = create_request method: "POST", headers: headers, body: body.to_json
      Hatty::Request.new(post_request).body.should eq nil
    end

    it "parses the body as JSON" do
      headers = HTTP::Headers{"Content-Type" => "application/json"}
      body = {"hello" => "world"}
      post_request = create_request method: "POST", headers: headers, body: body.to_json
      request = Hatty::Request.new(post_request)
      request.body.should eq body
    end

    # I could imagine screwing up the caching and accidentally not returning the JSON
    it "doesn't stop returning" do
      headers = HTTP::Headers{"Content-Type" => "application/json"}
      body = {"hello" => "world"}
      post_request = create_request method: "POST", headers: headers, body: body.to_json
      request = Hatty::Request.new(post_request)
      request.body.should eq body
      request.body.should eq body
      request.body.should eq body
    end
  end

  describe "#body(mappings)" do
    it "returns nil if there is no body" do
      post_request = create_request method: "POST"
      request = Hatty::Request.new(post_request)
      request.body(TestMapping).should eq nil
    end

    it "returns nil if the `Content-Type` is not `application/json`" do
      headers = HTTP::Headers{"Content-Type" => "text/plain"}
      body = {"hello" => "world"}
      post_request = create_request method: "POST", headers: headers, body: body.to_json
      request = Hatty::Request.new(post_request)
      request.body(TestMapping).should eq nil
    end

    it "maps the JSON to *mappings*" do
      headers = HTTP::Headers{"Content-Type" => "application/json"}
      body = {"hello" => "world"}
      post_request = create_request method: "POST", headers: headers, body: body.to_json
      request = Hatty::Request.new(post_request)
      body = request.body(TestMapping)
      body.should be_a TestMapping
      body.not_nil!.hello.should eq "world"
    end

    # Same as #body, i could imagine screwing up the caching and accidentally not returning the JSON
    it "doesn't stop returning" do
      headers = HTTP::Headers{"Content-Type" => "application/json"}
      body = {"hello" => "world"}
      post_request = create_request method: "POST", headers: headers, body: body.to_json
      request = Hatty::Request.new(post_request)
      body = request.body(TestMapping)
      body.should be_a TestMapping
      body.should be_a TestMapping
      body.should be_a TestMapping
      body.not_nil!.hello.should eq "world"
    end
  end

  describe "#form" do
    it "returns a hash with the formdata" do
      # Create formdata
      io = IO::Memory.new
      formdata = HTTP::FormData::Builder.new(io, "ILOVEHATTY")
      formdata.field "hello", "world"
      formdata.finish

      headers = HTTP::Headers{"Content-Type" => "multipart/form-data; boundary=ILOVEHATTY"}
      post_request = create_request method: "POST", headers: headers, body: io.to_s
      request = Hatty::Request.new(post_request)

      request.form.should eq({"hello" => "world"})
    end

    it "returns nil if the content type is not multipart/form-data" do
      # Create formdata
      io = IO::Memory.new
      formdata = HTTP::FormData::Builder.new(io, "ILOVEHATTY")
      formdata.field "hello", "world"
      formdata.finish

      headers = HTTP::Headers{"Content-Type" => "application/json"}
      post_request = create_request method: "POST", headers: headers, body: io.to_s
      request = Hatty::Request.new(post_request)

      request.form.should eq nil
    end

    it "returns nil if the body is empty" do
      headers = HTTP::Headers{"Content-Type" => "multipart/form-data; boundary=ILOVEHATTY"}
      post_request = create_request method: "POST", headers: headers
      request = Hatty::Request.new(post_request)

      request.form.should eq nil
    end

    it "doesn't stop returning" do
      # Create formdata
      io = IO::Memory.new
      formdata = HTTP::FormData::Builder.new(io, "ILOVEHATTY")
      formdata.field "hello", "world"
      formdata.finish

      headers = HTTP::Headers{"Content-Type" => "multipart/form-data; boundary=ILOVEHATTY"}
      post_request = create_request method: "POST", headers: headers, body: io.to_s
      request = Hatty::Request.new(post_request)

      request.form.should eq({"hello" => "world"})
      request.form.should eq({"hello" => "world"})
      request.form.should eq({"hello" => "world"})
    end
  end

  describe "#params" do
    it "returns a hash with the parameters" do
      get "/users/:id" do
      end
      http_request = create_request resource: "/users/1"
      request = Hatty::Request.new(http_request)
      request.params.should eq({"id" => "1"})
    end
  end

  describe "#parameters" do
    it "returns a hash with the parameters" do
      get "/users/:id" do
      end
      http_request = create_request resource: "/users/3"
      request = Hatty::Request.new(http_request)
      request.parameters.should eq({"id" => "3"})
    end
  end

  describe "#query" do
    it "returns a hash with the query parameters" do
      get "/query" do
      end

      http_request = create_request resource: "/query?awesome=true&works=hopefully"
      request = Hatty::Request.new(http_request)
      request.query.should eq({"awesome" => "true", "works" => "hopefully"})

      second_http_request = create_request resource: "/query"
      second_request = Hatty::Request.new(second_http_request)
      second_request.query.should eq({} of String => String)
    end
  end

  describe "#path" do
    it "returns the path" do
      http_request = create_request resource: "/users/1"
      Hatty::Request.new(http_request).path.should eq "/users/1"
    end
  end
end
