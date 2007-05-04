module GemInstaller
  class Autogem
    attr_writer :gem_command_manager, :gem_spec_manager, :gem_source_index_proxy
    def autogem(gems)
      @gem_source_index_proxy.refresh!
      reversed_gems = gems.reverse!
      @completed_names = []
      @completed_gems = []
      reversed_gems.each do |gem|
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
      process_gem_dependencies(gem)
    end
    
    def process_gem_dependencies(gem)
      # TODO: this method is duplicated in rogue_gem_finder.  Should abstract and take a block
      matching_gems = @gem_spec_manager.local_matching_gems(gem)
      matching_gems.each do |matching_gem|
        dependency_gems = @gem_command_manager.dependency(matching_gem.name, matching_gem.version.to_s)
        dependency_gems.each do |dependency_gem|
          process_gem(dependency_gem)
        end
      end
    end

    def invoke_require_gem_command(name, version)
      if Gem::RubyGemsVersion.index('0.8') == 0
        require_gem(name, version)
      else
        gem(name, version)
      end
    end
  end
end