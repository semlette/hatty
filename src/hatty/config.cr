module Hatty
  class Configuration
    @disable_powered_by = false
    property disable_powered_by : Bool

    @disable_logging = false
    property disable_logging : Bool
  end

  # :nodoc:
  module Config
    INSTANCE = Configuration.new
  end

  # Returns Hatty's configuration.
  # ```
  # Hatty.config.disable_powered_by = true
  def self.config
    Config::INSTANCE
  end

  # Calls the block with Hatty's configuration.
  # ```
  # Hatty.configure do |config|
  #   config.disable_powered_by = true
  # end
  # ```
  def self.configure
    yield Config::INSTANCE
  end
end
