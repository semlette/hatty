describe "get" do
  it "listens for GET requests" do
    called = false
    get "/get-test" do |request|
      called = true
      request.method.should eq "GET"
    end

    context = create_context(method: "GET", resource: "/get-test")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    called.should eq true
  end
end

describe "post" do
  it "listens for POST requests" do
    called = false
    post "/post-test" do |request|
      called = true
      request.method.should eq "POST"
    end

    context = create_context(method: "POST", resource: "/post-test")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    called.should eq true
  end
end

describe "put" do
  it "listens for PUT requests" do
    called = false
    put "/put-test" do |request|
      called = true
      request.method.should eq "PUT"
    end

    context = create_context(method: "PUT", resource: "/put-test")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    called.should eq true
  end
end

describe "delete" do
  it "listens for DELETE requests" do
    called = false
    delete "/delete-test" do |request|
      called = true
      request.method.should eq "DELETE"
    end

    context = create_context(method: "DELETE", resource: "/delete-test")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    called.should eq true
  end
end

describe "patch" do
  it "listens for PATCH requests" do
    called = false
    patch "/patch-test" do |request|
      called = true
      request.method.should eq "PATCH"
    end

    context = create_context(method: "PATCH", resource: "/patch-test")
    handler = Hatty::Handlers::Routing.new
    handler.call(context)

    called.should eq true
  end
end
