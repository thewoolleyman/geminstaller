module GemInstaller
  class FileReader
    def read(file_path)
      file_contents = nil
      if !File.exist?(file_path) then
        raise GemInstaller::GemInstallerError.new("Error: File #{file_path} does not exist at #{file_path}.  Please ensure this file exists\n")
      end

      file = nil
      begin
        file = do_open(file_path)
      rescue
        raise GemInstaller::GemInstallerError.new("Error: Unable open file #{file_path}.  Please ensure this file can be opened.\n")
      end

      begin
        do_read(file)
      rescue
        raise GemInstaller::GemInstallerError.new("Error: Unable read file #{file_path}.  Please ensure this file can be read.\n")
      end
    end
    
    def do_open(file_path)
      File.open(file_path)
    end
    
    def do_read(file)
      file.read
    end
  end
end