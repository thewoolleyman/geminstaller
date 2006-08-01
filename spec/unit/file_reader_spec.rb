dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/file_reader")

context "An existing file" do
  specify "should be openable" do
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    file_reader = GemInstaller::FileReader.new(testfile_path)
    file_contents = file_reader.read
    file_contents.should_equal('test')
  end
end
