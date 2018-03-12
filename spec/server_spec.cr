require "./spec_helper"

describe Hatty::Server do
  describe "#native" do
    it "returns the HTTP::Server" do
      server = Hatty::Server.new(3000)
      server.native.should be_a HTTP::Server
    end
  end

  it "includes the routing handler" do
    server = Hatty::Server.new(3000)
    handler = server.handlers.find do |handler|
      handler.is_a? Hatty::Handlers::Routing
    end

    handler.should be_a Hatty::Handlers::Routing
  end

  context "Hatty.config#disable_logging = true" do
    it "doesn't includes the logging handler" do
      Hatty.config.disable_logging = true
      server = Hatty::Server.new(3000)
      handler = server.handlers.find do |handler|
        handler.is_a? HTTP::LogHandler
      end

      handler.should eq nil
    end
  end

  context "Hatty.config#disable_logging = false" do
    it "includes the logging handler" do
      Hatty.config.disable_logging = false
      server = Hatty::Server.new(3000)
      handler = server.handlers.find do |handler|
        handler.is_a? HTTP::LogHandler
      end

      handler.should be_a HTTP::LogHandler
    end
  end
end
