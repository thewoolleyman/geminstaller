dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a NoninteractiveChooser instance which is passed an install-formatted list of both non-binary and binary gems" do
  setup do
    @noninteractive_chooser = GemInstaller::NoninteractiveChooser.new
    @question = "Select which gem to install for your platform (i686-darwin8.7.1)"
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

  specify "should raise error if there is no match" do
    should_raise_error("stubgem-nomatch", "1.0.0", "ruby")
    should_raise_error("stubgem-multiplatform", "1.0.1", "nomatch")
    should_raise_error("stubgem-multiplatform", "9", "mswin32")
  end
end

context "a NoninteractiveChooser instance which is passed an uninstall-formatted list of both non-binary and binary gems" do
  setup do
    @noninteractive_chooser = GemInstaller::NoninteractiveChooser.new
    @question = "Select RubyGem to uninstall"
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

  specify "should raise error if there is no match" do
    should_raise_error("stubgem-nomatch", "1.0.0", "ruby")
    should_raise_error("stubgem-multiplatform", "1.0.1", "nomatch")
    should_raise_error("stubgem-multiplatform", "9", "mswin32")
  end
end

def should_choose(expected_choice, name, version, platform)
  @noninteractive_chooser.specify_exact_gem_spec(name, version, platform)
  string, index = @noninteractive_chooser.choose(@question, @list)
  index.should==(expected_choice)
end

def should_raise_error(name, version, platform)
  @noninteractive_chooser.specify_exact_gem_spec(name, version, platform)
  lambda{ @noninteractive_chooser.choose(@question, @list) }.should_raise(GemInstaller::GemInstallerError)
end

