dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "RubyGems version warnings class" do
  before(:each) do
    @warnings_class = GemInstaller::RubyGemsVersionWarnings
    @warnings_class.should_receive(:allow_unsupported?).any_number_of_times.and_return(false)
  end
  
  it "warns properly if outdated" do
    @warnings_class.outdated_warning(:rubygems_version => '0.9.4').should match(/should update/m)
  end

  it "does not warn if not outdated" do
    @warnings_class.outdated_warning(:rubygems_version => '1.0.1').should be_nil
  end

  it "warns properly if incompatible" do
    @warnings_class.incompatible_warning(:rubygems_version => '0.9.5').should match(/compatibility/m)
    @warnings_class.incompatible_warning(:rubygems_version => '1.1.0').should match(/bugs/m)
  end

  it "does not warn if compatible" do
    @warnings_class.incompatible_warning(:rubygems_version => '1.0.1').should be_nil
    @warnings_class.incompatible_warning(:rubygems_version => '1.1.1').should be_nil
  end

end
