dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a NoninteractiveChooser instance which is passed an install-formatted list of both non-binary and binary gems" do
  setup do
    @noninteractive_chooser = GemInstaller::NoninteractiveChooser.new
    @noninteractive_chooser.list_type=(:install_list_type)
    @list = [
      "stubgem 1.0.0 (ruby)",
      "stubgem-multiplatform 1.0.1 (mswin32)",
      "stubgem-multiplatform 1.0.1 (ruby)",
      "stubgem-multiplatform 1.0.0 (mswin32)",
      "stubgem-multiplatform 1.0.0 (ruby)",
      "Cancel installation"
      ]
  end

  specify "should properly select with a binary platform" do
    should_choose(1, "stubgem-multiplatform", "1.0.1", "mswin32")
  end

  specify "should properly select with a ruby platform" do
    should_choose(2, "stubgem-multiplatform", "1.0.1", "ruby")
  end

  specify "should return nil if there is no match" do
    should_choose(nil, "stubgem-nomatch", "1.0.0", "ruby")
    should_choose(nil, "stubgem-multiplatform", "1.0.1", "nomatch")
    should_choose(nil, "stubgem-multiplatform", "9", "mswin32")
  end
end

context "a NoninteractiveChooser instance which is passed an uninstall-formatted list of both non-binary and binary gems" do
  setup do
    @noninteractive_chooser = GemInstaller::NoninteractiveChooser.new
    @noninteractive_chooser.list_type=(:uninstall_list_type)
    @list = [
      "stubgem-1.0.0",
      "stubgem-multiplatform-1.0.1-mswin32",
      "stubgem-multiplatform-1.0.1",
      "stubgem-multiplatform-1.0.0-mswin32",
      "stubgem-multiplatform-1.0.0",
      "All versions"
      ]
  end

  specify "should properly select with a binary platform" do
    should_choose(1, "stubgem-multiplatform", "1.0.1", "mswin32")
  end

  specify "should properly select with a ruby platform" do
    should_choose(2, "stubgem-multiplatform", "1.0.1", "ruby")
  end

  specify "should return nil if there is no match" do
    should_choose(nil, "stubgem-nomatch", "1.0.0", "ruby")
    should_choose(nil, "stubgem-multiplatform", "1.0.1", "nomatch")
    should_choose(nil, "stubgem-multiplatform", "9", "mswin32")
  end
end

def should_choose(expected_choice, name, version, platform)
  @noninteractive_chooser.specify_exact_gem_spec(name, version, platform)
  string, index = @noninteractive_chooser.choose(@list)
  index.should==(expected_choice)
end

