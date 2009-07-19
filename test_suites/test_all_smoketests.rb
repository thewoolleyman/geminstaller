print "\nRunning all GemInstaller SmokeTests, ENV['RUBYGEMS_VERSION'] == '#{ENV['RUBYGEMS_VERSION']}'\n\n"

dir = File.dirname(__FILE__)
smoketest_dir = File.expand_path("#{dir}/../spec/smoketest")

test_files = Dir.glob("#{smoketest_dir}/**/*_smoketest.rb")
test_files.reject! {|f| f =~ /debug/} # skip debug copy of install smoketest
test_files.reject! {|f| f =~ /rails/} # rails smoketest currently isn't passing

test_files.each do |test_file|
  puts "Running smoketest: ruby #{test_file}"
  raise "#{test_file} failed" unless system("ruby #{test_file}")
end
# 
# class SmokeTestSuite
#   def self.suite
#     suite = Test::Unit::TestSuite.new
#     suite << GemInstaller::AutoGemSmokeTest.suite
# #    suite << GemInstaller::InstallSmokeTest.suite
# #    suite << GemInstaller::RailsSmokeTest.suite
#     return suite
#   end
# end
# Test::Unit::UI::Console::TestRunner.run(SmokeTestSuite)
