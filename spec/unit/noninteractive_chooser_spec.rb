dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a NoninteractiveChooser instance which is passed an install-formatted list of both non-binary and binary gems" do
  setup do
    @noninteractive_chooser = GemInstaller::NoninteractiveChooser.new
    @question = "Select which gem to install for your platform (i686-darwin8.7.1)"
    @list = [
      "stubgem-multiplatform 2.0.0 (ruby)",
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

  specify "should properly select with a binary platform and nil name/version" do
    should_choose(1, nil, nil, "mswin32")
  end
  
  specify "should properly select with a ruby platform and nil name/version" do
    should_choose(0, nil, nil, "ruby")
  end
  
  specify "should select first matching platform if list does not match name exactly (it's a dependency gem)" do
    should_choose(1, 'stubgem', '1.2.3', "mswin32")
  end
end

context "a NoninteractiveChooser instance which is passed an install-formatted list for a dependent gem" do
  setup do
    @noninteractive_chooser = GemInstaller::NoninteractiveChooser.new
    @question = "Select which gem to install for your platform (i686-darwin8.7.1)"
    @list = [
      "stubgem-dependency 2.0.0 (ruby)",
      "stubgem-dependency 1.0.1 (mswin32)",
      "stubgem-dependency 1.0.1 (ruby)",
      "stubgem-dependency 1.0.0 (mswin32)",
      "stubgem-dependency 1.0.0 (ruby)",
      "Cancel installation"
      ]
  end

  specify "should select the first matching platform" do
    should_choose(1, 'stubgem', '1.2.3', "mswin32")
  end

  specify "should raise error if there is no match" do
    should_raise_error("stubgem-nomatch", "1.0.0", "solaris")
  end

  specify "should have properly formatted error" do
    begin
      @noninteractive_chooser.choose(@question, @list, "stubgem-nomatch", "1.0.0", "solaris")
    rescue GemInstaller::GemInstallerError => e
      @list.collect! do |item|
        Regexp.escape(item)
      end
      list_regexp = @list[0..4].join(".*")
      tmp = "\"stubgem-nomatch 1.0.0 (solaris)\""
      e.message.should_match(/.*Unable to select gem from list.*#{list_regexp}/m)
    end
  end
end

context "a NoninteractiveChooser instance which is passed an uninstall-formatted list of both non-binary and binary gems" do
  setup do
    @noninteractive_chooser = GemInstaller::NoninteractiveChooser.new
    @question = "Select RubyGem to uninstall"
    @list = [
      "stubgem-multiplatform 2.0.0 (ruby)",
      "stubgem-multiplatform-1.0.1-mswin32",
      "stubgem-multiplatform-1.0.1",
      "stubgem-multiplatform-1.0.0-mswin32",
      "stubgem-multiplatform-1.0.0",
      "stubgem-1.0.0",
      "All versions"
      ]
  end

  specify "should properly select with a binary platform" do
    should_choose(1, "stubgem-multiplatform", "1.0.1", "mswin32")
  end

  specify "should properly select with a ruby platform" do
    should_choose(2, "stubgem-multiplatform", "1.0.1", "ruby")
  end

  specify "should properly select with a binary platform and nil name/version" do
    should_choose(1, nil, nil, "mswin32")
  end
  
  specify "should properly select with a ruby platform and nil name/version" do
    should_choose(0, nil, nil, "ruby")
  end
  
  specify "should do an exact name match (not substring)" do
    should_choose(5, "stubgem", "1.0.0", "ruby")
  end

  specify "should properly select if there is no match" do
    should_raise_error("stubgem-nomatch", "1.0.0", "ruby")
    should_raise_error("stubgem-multiplatform", "1.0.1", "nomatch")
    should_raise_error("stubgem-multiplatform", "9", "mswin32")
  end
end

def should_choose(expected_choice, name, version, platform)
  string, index = @noninteractive_chooser.choose(@question, @list, name, version, platform)
  index.should==(expected_choice)
end

def should_raise_error(name, version, platform)
  lambda{ @noninteractive_chooser.choose(@question, @list, name, version, platform) }.should_raise(GemInstaller::GemInstallerError)
end

