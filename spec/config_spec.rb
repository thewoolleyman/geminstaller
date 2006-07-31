require File.dirname(__FILE__) + '/spec_helper'
require 'geminstaller/config'

class StubFile
  def exist?
    return true;
  end
  def open(filepath)
    return "{\"gems\"=>[{\"name\"=>\"gem-one\"}, {\"name\"=>\"gem-two\"}]}"
  end
end


context "A Config with no config file location specified" do
  setup do
  end

  specify "should read required gems from the default config file location" do
    GemInstaller::Config.use_class(:File, StubFile ) do
      config = GemInstaller::Config.new
      required_gems = config.required_gems
      ["gem-one", "gem-two"].should_equal(required_gems)
    end
  end
end
