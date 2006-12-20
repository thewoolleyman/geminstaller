dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a VersionSpecifier instance" do
  setup do
    @version_specifier = GemInstaller::VersionSpecifier.new
  end

  specify "should specify ambiguous version requirements when requirments are an array" do    
    should_specify("> 0", ['1','0'], '1')
    should_specify("= 1", ['2','1', '0'], '1')
    should_specify("> 1.2.3", ['2.0','1.2.4,','1.2.4','0.3'], '2.0')
  end
  
  specify "should specify ambiguous version requirements when requirments are a comma-delimited string" do    
    should_specify("> 0", '1, 0', '1')
    should_specify("= 1", '2, 1, 0', '1')
    should_specify("> 1.2.3", '2.0, 1.2.4, 1.2.4, 0.3', '2.0')
  end
  
  def should_specify(version_requirement, available_versions, expected_specified_version)
    specified_version = @version_specifier.specify(version_requirement, available_versions)
    specified_version.should==(expected_specified_version)
  end
end
