dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "An existing file" do
  # TODO: should test the exceptions and messages too...
  specify "should be openable" do
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    file_reader = GemInstaller::FileReader.new
    file_contents = file_reader.read(testfile_path)
    file_contents.should==('test')
  end
end
