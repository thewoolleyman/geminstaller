module GemInstaller
  class Autogem
    attr_writer :gem_command_manager
    def autogem(gems)
      reversed_gems = gems.reverse!
      @completed_names = []
      @completed_gems = []
      reversed_gems.each do |gem|
        load_gem(gem)
      end
      @completed_gems
    end
    
    def load_gem(gem)
      unless @completed_names.index(gem.name)
        invoke_require_gem_command(gem.name, gem.version)
        @completed_names << gem.name
        @completed_gems << gem
      end
      load_gem_dependencies(gem)
    end
    
    def load_gem_dependencies(gem)
      # TODO: some of this logic is duplicated with missing_dependency_finder.  Should refactor
      # gem_command_manager.dependency to return ruby_gems instead of a line
      matching_gem_specs = @gem_command_manager.local_matching_gem_specs(gem)
      matching_gem_specs.each do |matching_gem_spec|
        dependency_output_lines = @gem_command_manager.dependency(matching_gem_spec.name, matching_gem_spec.version.to_s)
        dependency_output_lines.each do |dependency_output_line|
          name = dependency_output_line.split(' ')[0]
          version_spec = dependency_output_line.split(/[()]/)[1]
          dependency_gem = GemInstaller::RubyGem.new(name, :version => version_spec)
          load_gem(dependency_gem)
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