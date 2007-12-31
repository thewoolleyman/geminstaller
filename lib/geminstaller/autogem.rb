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
      unless @completed_names.index(gem.name) or gem.no_autogem
        invoke_require_gem_command(gem.name, gem.version)
        @completed_names << gem.name
        @completed_gems << gem
      end
    end
    
    def invoke_require_gem_command(name, version)
      if GemInstaller::RubyGemsVersionChecker.matches?('< 0.9')
        require_gem(name, version)
      else
        # TODO: should we check true/false result of gem method?
        gem(name, version)
      end
    end
  end
end