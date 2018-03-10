# Hatty [![CircleCI](https://circleci.com/gh/semlette/hatty.svg?style=svg)](https://circleci.com/gh/semlette/hatty)

A library for creating HTTP services in Crystal

> WORK IN PROGRESS. Please don't use this in production, it will probably break. I actually don't think it will, but I don't promise anything.

```crystal
require "hatty"

get "/" do |request, response|
  response.send_text "Hello there!"
end

Hatty.start
```

## Installing

Add this snippet to your `shard.yml` file

```yml
dependencies:
  hatty:
    github: semlette/hatty
```

## Usage

```crystal
require "hatty"

# Define handlers using `get`, `post`, `put`, `delete` and `patch`

module MyApi
  # Imaginary API
  # ...
end

get "/users/:id" do |request, response|
  user = MyApi.get_user by_id: request.params["id"]
  response.send_json({ data: user })
end

post "/users" do |request, response|
  name = response.body["name"]
  new_user = MyApi.create_user(name)
  response.send_json({ success: true, data: new_user })
end

delete "/users/:id" do |request, response|
  token = request.headers["Authorization"]?
  is_admin = MyApi.is_admin?(token)
  if is_admin
    MyApi.delete_user by_id: request.params["id"]
    response.send_json({ "success" => true })
  else
    # Send status 401 Unauthorized
    response.send_status 401
  end
end

Hatty.start
```

Every handler receives a [request](https://semlette.github.io/hatty/Hatty/Request) and a [response](https://semlette.github.io/hatty/Hatty/Response). The request contains information about the request like the [headers](), the [body](https://semlette.github.io/hatty/Hatty/Request#body-instance-method), [url queries]() and [parameters](https://semlette.github.io/hatty/Hatty/Request#params%3AHash%28String%2CString%29-instance-method). The response has properties like the [status code](), [headers](https://semlette.github.io/hatty/Hatty/Response#headers%3AHTTP%3A%3AHeaders-instance-method) and a lot of helper methods for sending stuff back to the client.

* [All handlers methods](https://semlette.github.io/hatty/toplevel.html)
* [Starting hatty](https://semlette.github.io/hatty/Hatty#start%28port%3D3000%29-class-method)

### Sending stuff

```crystal
get "/" do |request, response|
  # Note: You can only call `#send...` once
  response.send "<!DOCTYPE><html><body>I have no Content-Type</body></html>"
  response.send_text "I am text/plain"
  response.send_json({ "content-type" => "application/json" })
  response.send_status 404
end
```

[API documentation for `Response`](https://semlette.github.io/hatty/Hatty/Response)

### Status codes

#### Setting the status code

```crystal
get "/admin" do |request, response|
  response.status_code = 401
  response.send_text "Unauthorized."
end
```

#### Using status handlers

Status handlers are handlers that respond to a specific status code. When you call `Response#send_status`, the request is passed to the status handler with the same status code. If a handler raises an uncaught error, Hatty sends the request to the `500` status handler. It also passes requests with no handler to the `404` status handler.

```crystal
get "/private" do |request, response|
  response.send_status 404
end

status 404 do |request, response|
  response.send_text "Oops, file not found. ¯\_(ツ)_/¯"
end
```

#### Global status handler

Instead of defining a status handler for every status code, you can define a Global Status Handler™. The global status handler will receive all status codes not handled by the status handlers. If you create a status handler for `404` and a global status handler, the global status handler will not receive `404` requests.

```crystal
status do |code, request, response|
  response.send_text "Oops! Error code #{code}"
end
```

[API documentation for `status`](https://semlette.github.io/hatty/toplevel.html#status%28code%2C%26handler%3AHatty%3A%3AHandler%29-class-method)

[API documentation for `Response#send_status`](https://semlette.github.io/hatty/Hatty/Response#send_status%28status_code%29%3ANil-instance-method)

## Testing

Hatty comes with a testing module which helps you test your routes. Inspired by [spec-kemal](https://github.com/kemalcr/spec-kemal), requiring `hatty/testing` imports methods that allows you to test your routes.

Methods

* [`get`](https://semlette.github.io/hatty/toplevel#get%28resource%2Cheaders%3AHTTP%3A%3AHeaders%3F%3Dnil%2Cbody%3AString%3F%3Dnil%29%3AHatty%3A%3ATesting%3A%3AResponse-class-method)
* [`post`](https://semlette.github.io/hatty/toplevel#post%28resource%2Cheaders%3AHTTP%3A%3AHeaders%3F%3Dnil%2Cbody%3AString%3F%3Dnil%29%3AHatty%3A%3ATesting%3A%3AResponse-class-method)
* [`put`](https://semlette.github.io/hatty/toplevel#put%28resource%2Cheaders%3AHTTP%3A%3AHeaders%3F%3Dnil%2Cbody%3AString%3F%3Dnil%29%3AHatty%3A%3ATesting%3A%3AResponse-class-method)
* [`delete`](https://semlette.github.io/hatty/toplevel#delete%28resource%2Cheaders%3AHTTP%3A%3AHeaders%3F%3Dnil%2Cbody%3AString%3F%3Dnil%29%3AHatty%3A%3ATesting%3A%3AResponse-class-method)
* [`patch`](https://semlette.github.io/hatty/toplevel#patch%28resource%2Cheaders%3AHTTP%3A%3AHeaders%3F%3Dnil%2Cbody%3AString%3F%3Dnil%29%3AHatty%3A%3ATesting%3A%3AResponse-class-method)

**`app.cr`**

```crystal
require "hatty"

get "/api" do |request, response|
  response.send_json({ "data" => "insert data here" })
end

Hatty.start
```

**`app_spec.cr`**

```crystal
require "./app"
require "hatty/testing"

describe "GET /api" do
  it "returns json" do
    #         `get` along with other methods are provided by `hatty/testing`
    response = get "/api"

    response.status_code.should eq 200
    response.json?.should be_true
  end
end
```
