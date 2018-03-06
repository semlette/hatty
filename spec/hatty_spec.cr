require "./spec_helper"
require "yaml"

describe "Hatty::VERSION" do
  it "is the right version" do
    shard = File.open "./shard.yml"
    yaml = YAML.parse shard
    Hatty::VERSION.should eq yaml["version"].as_s
  end
end
