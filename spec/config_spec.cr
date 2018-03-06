require "./spec_helper"

describe "Hatty#config" do
  it "returns the configuration" do
    config = Hatty.config
    config.should be_a Hatty::Configuration
  end
end

describe "Hatty#configure" do
  it "yields the configuration" do
    Hatty.configure do |config|
      config.should be_a Hatty::Configuration
    end
  end
end