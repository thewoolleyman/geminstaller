module GemInstaller
  class AutoGem
    def autogem(gems)
      reversed_gems = gems.reverse!
      completed_names = []
      completed_gems = []
      reversed_gems.each do |gem|
        unless completed_names.index(gem.name)
          invoke_require_gem_command(gem.name, gem.version)
          completed_names << gem.name
          completed_gems << gem
        end
      end
      completed_gems
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