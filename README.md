# Hatty

A library for creating HTTP services in Crystal

```crystal
require "hatty"

get "/" do |request, response|
  response.send_text "Hello there!"
end

Hatty.start
```

## Installing

Add this snippet to your `shards.yml` file

```yml
dependencies:
  hatty:
    github: semlette/hatty
```

## Usage

> All of the following examples expects that Hatty has been required and started.

```crystal
require "hatty"

# ...

Hatty.start
```

### Listening for requests

```crystal
get "/" do |request, response|
  response.send_text "It's alive!"
end

post "/" do |request, response|
  # ...
end

put "/" do |request, response|
  # ...
end

delete "/" do |request, response|
  # ...
end

patch "/" do |request, response|
  # ...
end
```
