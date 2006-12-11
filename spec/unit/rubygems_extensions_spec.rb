dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "the extensions to RubyGems" do
  setup do
    # Can't use an rspec mock here, because you can't mock the 'puts' method
    stub_in_stream = StringIO.new("1")
    stub_out_stream = StringIO.new("","w")
    @rubygems_extensions = Gem::StreamUI.new(stub_in_stream, stub_out_stream)
    Gem::StreamUI.noninteractive_chooser = nil
  end

  specify "should have code coverage for code which is not used by GemInstaller but still had to be copied" do
    @rubygems_extensions.choose_from_list("question", ["item 1"])
  end
end