require "./spec_helper"

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

  describe "#params" do
    it "returns a hash with the parameters" do
      get "/users/:id" do
      end

      http_request = create_request resource: "/users/1"
      request = Hatty::Request.new(http_request)
      request.params.should eq({ "id" => "1" })
    end
  end

  describe "#path" do
    it "returns the path" do
      http_request = create_request resource: "/users/1"
      Hatty::Request.new(http_request).path.should eq "/users/1"
    end
  end
end
