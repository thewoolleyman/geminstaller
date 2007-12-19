dir = File.dirname(__FILE__)
specdir = File.expand_path("#{dir}/../spec")
require File.expand_path("#{specdir}/helper/spec_helper")

spec_files = Dir.glob("#{specdir}/**/*_spec.rb")
# put test_gem_home_spec first so we only have to perform the install once
spec_files.unshift(Dir.glob("#{specdir}/unit/test_gem_home_spec.rb")[0])
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

retval = 1
begin
  require 'spec'
  retval = ::Spec::Runner::CommandLine.run(rspec_options)
ensure
  GemInstaller::TestGemHome.reset
end
retval ||= 0
raise "Specs failed, return value = #{retval}" unless retval == 0
