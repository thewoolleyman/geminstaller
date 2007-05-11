# TODO: This is the only thing I could hack together in order to run the specs after upgrading
# to Rspec 0.9.3.  Need to be back to all specs being runnable via 'rake' or 'test_all'
# Are there any good examples of running rspec for a non-rails project, and allowing post-suite hooks?

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

$behaviour_runner  = ::Spec::Runner::OptionParser.new.create_behaviour_runner(args, STDERR, STDOUT, false)

retval = 1
begin
  retval = $behaviour_runner.run(args, false)
ensure
  $server_was_stopped = GemInstaller::EmbeddedGemServer.stop
  GemInstaller::TestGemHome.reset
end
retval ||= 0
raise "Specs failed, return value = #{retval}" unless retval == 0
