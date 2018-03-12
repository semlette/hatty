require "./spec_helper"

describe "Handlers::Routing" do
  it "calls next if the request is not an http request" do
    sent = false

    get "/" do
      sent = true
    end

    request = HTTP::Request.new("GET", "/", nil, nil, "WRONG!!!")
    io = IO::Memory.new
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    sent.should eq false
  end

  it "sends the request to the right handler" do
    sent = false

    get "/" do
      sent = true
    end

    context = create_context(resource: "/")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    sent.should eq true
  end

  it "respects parameters" do
    recieved = false

    get "/param/:name" do
      recieved = true
    end

    context = create_context(resource: "/param/recieved")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    recieved.should eq true
  end

  it "returns 404 if no handler was found" do
    context = create_context(resource: "/i-dont-exist")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    context.response.status_code.should eq 404
  end

  it "returns 500 and raises if the handler fucks up" do
    get "/crap" do
      raise "oh crap"
    end

    context = create_context(resource: "/crap")

    expect_raises Exception do
      handler = Hatty::Handlers::Routing.new
      handler.call(context)
    end

    context.response.status_code.should eq 500
  end

  it "passes `#send_status` to the status handler" do
    forwarded = false

    get "/status" do |request, response|
      response.send_status 401
    end

    status 401 do |request, response|
      forwarded = true
      response.send_text "Unauthorized!"
    end

    context = create_context(resource: "/status")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    forwarded.should eq true
  end

  it "passes `#send_status` to the status handler with the same status code" do
    get "/status-code" do |request, response|
      response.send_status 403
    end

    status 403 do |request, response|
      response.send_text "I should have status code 403"
    end

    context = create_context(resource: "/status-code")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    context.response.status_code.should eq 403
  end

  it "sends the request to the global status handler if there is no status handler" do
    called = false

    status do |code, request, response|
      called = true
      code.should eq 300
    end

    get "/unhandled-status-code" do |request, response|
      response.send_status 300
    end

    context = create_context(resource: "/unhandled-status-code")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    called.should eq true
  end
end
