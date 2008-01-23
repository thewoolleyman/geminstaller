module GemInstaller
  class Autogem
    attr_writer :gem_command_manager, :gem_source_index_proxy
    def autogem(gems)
      @gem_source_index_proxy.refresh!
      @completed_names = []
      @completed_gems = []
      gems.each do |gem|
        process_gem(gem)
      end
      @completed_gems
    end
    
    def process_gem(gem)
      name = gem.name
      version = gem.version
      unless @completed_names.index(name) or gem.no_autogem
        begin
          invoke_require_gem_command(name, version)
        rescue Gem::LoadError => load_error
          load_error_message = load_error.message
          load_error_message.strip!
          error_message = "Error: GemInstaller attempted to load gem '#{name}', version '#{version}', but that version is not installed.  Use GemInstaller to install the gem.  Original Gem::LoadError was: '#{load_error_message}'"
          raise GemInstaller::GemInstallerError.new(error_message)
        end
        @completed_names << name
        @completed_gems << gem
      end
    end
    
    def invoke_require_gem_command(name, version)
      if GemInstaller::RubyGemsVersionChecker.matches?('< 0.9')
        require_gem(name, version)
      else
        # TODO: check true/false result of gem method, print debug message if false (already loaded)
        result = gem(name, version)
      end
    end
  end
end