dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/config")

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
  end
end
