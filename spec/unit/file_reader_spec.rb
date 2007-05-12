dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "An existing file" do
  it "should be openable" do
    file_reader = GemInstaller::FileReader.new
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    file_contents = file_reader.read(testfile_path)
    file_contents.should==('test')
  end
end

describe "A nonexistent file" do
  it "should return an error message" do
    file_reader = GemInstaller::FileReader.new
    testfile_path = File.expand_path("missing_file.txt")
    lambda { file_reader.read(testfile_path) }.should raise_error(GemInstaller::MissingFileError)
  end
end

describe "An unopenable file" do
  it "should return an error message" do
    file_reader = GemInstaller::FileReader.new
    file_reader.instance_eval {
      def do_open(file) 
        raise RuntimeError
      end
    }
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    lambda { file_reader.read(testfile_path) }.should raise_error(GemInstaller::GemInstallerError)
  end
end

describe "A file that cannot be read" do
  it "should return an error message" do
    file_reader = GemInstaller::FileReader.new
    file_reader.instance_eval {
      def do_read(file) 
        raise RuntimeError
      end
    }
    testfile_path = File.expand_path("#{dir}/testfile.txt")
    lambda { file_reader.read(testfile_path) }.should raise_error(GemInstaller::GemInstallerError)
  end
end
