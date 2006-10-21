module GemInstaller
  class FileReader
    def read(file_path)
      file_contents = nil
      if !File.exist?(file_path) then
        $stderr.print "Error: File #{file_path} does not exist.  Please ensure this file exists\n\n"
        raise
      end

      file = nil
      begin
        file = File.open(file_path)
      rescue
        $stderr.print "Error: Unable open file #{file_path}.  Please ensure this file can be opened.\n\n"
        raise
      end

      begin
        file.read
      rescue
        $stderr.print "Error: Unable read file #{file_path}.  Please ensure this file can be read.\n\n"
        raise
      end
    end
  end
end