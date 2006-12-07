dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "An existing file" do
  specify "should be openable" do
    file_reader = GemInstaller::FileReader.new
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    file_contents = file_reader.read(testfile_path)
    file_contents.should==('test')
  end
end

context "A nonexistent file" do
  specify "should return an error message" do
    file_reader = GemInstaller::FileReader.new
    testfile_path = File.expand_path("missing_file.txt")
    lambda { file_reader.read(testfile_path) }.should_raise GemInstaller::GemInstallerError
  end
end

context "An unopenable file" do
  specify "should return an error message" do
    file_reader = GemInstaller::FileReader.new
    file_reader.instance_eval {
      def do_open(file) 
        raise RuntimeError
      end
    }
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    lambda { file_reader.read(testfile_path) }.should_raise GemInstaller::GemInstallerError
  end
end

context "A file that cannot be read" do
  specify "should return an error message" do
    file_reader = GemInstaller::FileReader.new
    file_reader.instance_eval {
      def do_read(file) 
        raise RuntimeError
      end
    }
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    lambda { file_reader.read(testfile_path) }.should_raise GemInstaller::GemInstallerError
  end
end
