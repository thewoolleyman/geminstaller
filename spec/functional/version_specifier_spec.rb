dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "a VersionSpecifier instance" do
  before(:each) do
    @version_specifier = GemInstaller::VersionSpecifier.new
  end

  it "should specify ambiguous version requirements when requirments are an array" do    
    should_specify("> 0", ['1','0'], '1')
    should_specify("= 1", ['2','1', '0'], '1')
    should_specify("> 1.2.3", ['2.0','1.2.4,','1.2.4','0.3'], '2.0')
  end
  
  it "should specify ambiguous version requirements when requirments are a comma-delimited string" do    
    should_specify("> 0", '1, 0', '1')
    should_specify("= 1", '2, 1, 0', '1')
    should_specify("> 0.3.13.2", '0.3.13.4, 0.3.13.3, 0.3.13.2, 0.3.13.1', '0.3.13.4')
    should_specify("> 1.2.3", '2.0, 1.2.4, 1.2.4, 0.3', '2.0')
  end
  
  it "should handle ~> version requirement operator (greater minor version ok, but not major)" do
    should_specify("~> 1.2", '2.1, 2.0, 1.3, 1.2, 1.1', '1.3')
  end

  # TODO: Should this work?  Gem::Version::Requirement says it should...
#  specify "should handle multiple version requirements" do    
#    should_specify("> 0.3.13.1, < 0.3.13.4", '0.3.13.4, 0.3.13.3, 0.3.13.2, 0.3.13.1', '0.3.13.3')
#  end

  it "should throw an error if no matching versions are found" do    
    lambda { @version_specifier.specify("> 2", '2, 1') }.should raise_error(GemInstaller::GemInstallerError)
    lambda { @version_specifier.specify("!= 2", '2') }.should raise_error(GemInstaller::GemInstallerError)
  end
  
  it "should include name of gem in error message, if it is specified" do    
    begin
      @version_specifier.specify("!= 2", '2', 'gem_name')
    rescue GemInstaller::GemInstallerError => e
      e.message.should match(/gem_name/)
    end
  end

  def should_specify(version_requirement, available_versions, expected_specified_version)
    specified_version = @version_specifier.specify(version_requirement, available_versions)
    specified_version.should==(expected_specified_version)
  end
end
