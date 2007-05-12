dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "a NoninteractiveChooser instance which is passed an install-formatted list of both non-binary and binary gems" do
  before(:each) do
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

  it "should properly select with a binary platform" do
    should_choose(1, "stubgem-multiplatform", "1.0.1", ["mswin32"])
  end

  it "should properly select with a substring of a binary platform if the list is not for the dependent gem" do
    should_choose(1, "stubgem", "1.0.1", ["mswin"])
  end

  it "should properly select with a ruby platform" do
    should_choose(2, "stubgem-multiplatform", "1.0.1", ["ruby"])
  end

  it "should properly select with a binary platform and nil name/version" do
    should_choose(1, nil, nil, ["mswin32"])
  end
  
  it "should properly select with a ruby platform and nil name/version" do
    should_choose(0, nil, nil, ["ruby"])
  end
  
  it "should select first matching platform if list does not match name exactly (it's a dependency gem)" do
    should_choose(1, 'stubgem', '1.2.3', ["mswin32"])
  end
end

describe "a NoninteractiveChooser instance which is passed an install-formatted list for a dependent gem" do
  before(:each) do
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

  it "should select the first matching platform" do
    should_choose(1, 'stubgem', '1.2.3', ["mswin32"])
  end

  it "should raise error if there is no match" do
    should_raise_error("stubgem-nomatch", "1.0.0", ["solaris"])
  end

  it "should have properly formatted error" do
    begin
      @noninteractive_chooser.choose(@question, @list, "stubgem-nomatch", "1.0.0", ["solaris","mvs"])
    rescue GemInstaller::GemInstallerError => e
      @list.collect! do |item|
        Regexp.escape(item)
      end
      list_regexp = @list[0..4].join(".*")
      dependent_gem_regexp = Regexp.escape('"stubgem-nomatch 1.0.0 (solaris or mvs)"')
      e.message.should match(/.*Unable to select gem from list.*#{dependent_gem_regexp}.*#{list_regexp}/m)
    end
  end
end

describe "a NoninteractiveChooser instance which is passed an uninstall-formatted list of both non-binary and binary gems" do
  before(:each) do
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

  it "should properly select with a binary platform" do
    should_choose(1, "stubgem-multiplatform", "1.0.1", ["mswin32"])
  end

  it "should properly select with a ruby platform" do
    should_choose(2, "stubgem-multiplatform", "1.0.1", ["ruby"])
  end

  it "should properly select with a binary platform and nil name/version" do
    should_choose(1, nil, nil, ["mswin32"])
  end
  
  it "should properly select with a ruby platform and nil name/version" do
    should_choose(0, nil, nil, ["ruby"])
  end
  
  it "should do an exact name match (not substring)" do
    should_choose(5, "stubgem", "1.0.0", ["ruby"])
  end

  it "should properly select if there is no match" do
    should_raise_error("stubgem-nomatch", "1.0.0", ["ruby"])
    should_raise_error("stubgem-multiplatform", "1.0.1", ["nomatch"])
    should_raise_error("stubgem-multiplatform", "9", ["mswin32"])
  end

  it "should raise error if there is more than one platform specified to uninstall" do
    should_raise_error("stubgem", "1.0.0", ["ruby", "mswin32"])
  end

  it "should raise error if the question is not a recognized list prompt" do
    @question = "invalid question prompt"
    should_raise_error("stubgem", "1.0.0", ["ruby"])
  end

  it "should raise error if valid_platforms is not specified as an array" do
    should_raise_error("stubgem", "1.0.0", "ruby")
  end

end

def should_choose(expected_choice, name, version, valid_platforms)
  string, index = @noninteractive_chooser.choose(@question, @list, name, version, valid_platforms)
  index.should==(expected_choice)
end

def should_raise_error(name, version, valid_platforms)
  lambda{ @noninteractive_chooser.choose(@question, @list, name, version, valid_platforms) }.should raise_error(GemInstaller::GemInstallerError)
end

