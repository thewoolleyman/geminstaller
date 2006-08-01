require 'rubygems'
require 'spec'

args = ARGV.dup
unless args.include?("-f") || args.include?("--format")
  args << "--format"
  args << "specdoc"
end
args << "--diff"
args << $0
$context_runner  = ::Spec::Runner::OptionParser.create_context_runner(args, false, STDERR, STDOUT)

at_exit do
  unless context_runner.instance_eval {@reporter}.instance_eval {@start_time}
    context_runner.run(false)
  end
end