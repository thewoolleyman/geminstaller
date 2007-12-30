print "\nRunning all GemInstaller Tests, ENV['RUBYGEMS_VERSION'] == '#{ENV['RUBYGEMS_VERSION']}'\n\n"

dir = File.dirname(__FILE__)
specdir = File.expand_path("#{dir}/../spec")
require File.expand_path("#{specdir}/helper/spec_helper")

spec_files = Dir.glob("#{specdir}/**/*_spec.rb")

# put test_gem_home_spec first so we only have to perform the install once
test_gem_home_path = Dir.glob("#{specdir}/functional/test_gem_home_spec.rb")[0]
spec_files.delete(test_gem_home_path)
spec_files.unshift(test_gem_home_path)
spec_files.uniq

args = spec_files
args << "--color"
args << "--format"
args << "specdoc"
args << "--diff"
args << "unified"

# append generated args to ARGV.  THis may break if incompatible args are specified, 
# but I don't know a better way to invoke Rspec 1.1.1 programatically and check the return value
ARGV.concat(args)

success = false
begin
  require 'spec'
  success = ::Spec::Runner::CommandLine.run(rspec_options)
ensure
  GemInstaller::TestGemHome.reset
end
# not sure what Spec::Runner::CommandLine.run can return, but fail if it's not boolean as expected
raise "unexpected non-boolean return value from Spec::Runner::CommandLine.run(rspec_options)" unless success == true || success == false

raise "Specs failed" unless success