require 'test/unit'

dir = File.dirname(__FILE__)
#@@test_files = Dir.glob("#{dir}/../spec/**/*_spec.rb")
@@test_files = Dir.glob("#{dir}/../spec/**/*_spec.rb")
@@test_files.each {|x| require File.expand_path(x)}

class TestSuite
  def self.suite
    suite = Test::Unit::TestSuite.new

    @@test_files.each do |filename|
      File.open(filename) do |file|
        file.each_line do |line|
          if match = (/class\s+(\w+Test)/).match(line)
           suite << eval(match[1] + ".suite")
          end
        end
      end
    end
    return suite

  end
end

result = Test::Unit::AutoRunner.run
exit result
