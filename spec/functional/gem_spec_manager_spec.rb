dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an GemSpecManager instance" do
  setup do
    @GemSpecManager = GemInstaller::GemSpecManager.new
  end

  specify "should act as a proxy for GemSourceIndexProxy at this point in the refactoring" do
    
  end

end


