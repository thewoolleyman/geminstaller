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

def run_context_runner
  exit context_runner.run(true)
end

at_exit do
  run_context_runner
end
