dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "An existing file" do
  specify "should be openable" do
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    file_reader = GemInstaller::FileReader.new
    file_contents = file_reader.read(testfile_path)
    file_contents.should==('test')
  end
end

context "A missing file" do
  specify "should return an error message" do
    testfile_path = File.expand_path("missing_file.txt")
    file_reader = GemInstaller::FileReader.new
    lambda { file_reader.read(testfile_path) }.should_raise GemInstaller::GemInstallerError
  end
end
