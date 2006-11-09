module GemInstaller
  class FileReader
    def read(file_path)
      file_contents = nil
      if !File.exist?(file_path) then
        raise GemInstaller::GemInstallerError.new("Error: File #{file_path} does not exist at #{file_path}.  Please ensure this file exists\n")
      end

      file = nil
      begin
        file = File.open(file_path)
      rescue
        raise GemInstaller::GemInstallerError.new("Error: Unable open file #{file_path}.  Please ensure this file can be opened.\n")
      end

      begin
        file.read
      rescue
        raise GemInstaller::GemInstallerError.new("Error: Unable read file #{file_path}.  Please ensure this file can be read.\n")
      end
    end
  end
end