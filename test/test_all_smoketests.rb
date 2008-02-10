print "\nRunning all GemInstaller SmokeTests, ENV['RUBYGEMS_VERSION'] == '#{ENV['RUBYGEMS_VERSION']}'\n\n"

dir = File.dirname(__FILE__)
smoketest_dir = File.expand_path("#{dir}/../spec/smoketest")

test_files = Dir.glob("#{smoketest_dir}/**/*_smoketest.rb")

test_files.each do |test_file|
  require test_file
end
