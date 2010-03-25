module GemInstaller
  class SourceIndexSearchAdapter
    attr_writer :gem_source_index_proxy
    
    def all_local_specs
      if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
        search_less_than_or_equal_0_9_4('',GemInstaller::RubyGem.default_version)
      else
        dependency = Gem::Dependency.new('', GemInstaller::RubyGem.default_version)
        @gem_source_index_proxy.refresh!
        @gem_source_index_proxy.search(dependency, false)
      end
    end

    def search(gem, version_requirement, platform_only = false)
      if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
        gem_pattern = /^#{gem.regexp_escaped_name}$/
        search_less_than_or_equal_0_9_4(gem_pattern, version_requirement)
      else
        search_greater_than_0_9_4(gem, version_requirement, platform_only)
      end
    end
    
    def search_less_than_or_equal_0_9_4(gem_pattern, version_requirement)
      @gem_source_index_proxy.refresh!
      @gem_source_index_proxy.search(gem_pattern, version_requirement)
    end
    
    def search_greater_than_0_9_4(gem, version_requirement, platform_only = false)
      dependency = nil
      begin
        dependency = Gem::Dependency.new(gem.name, version_requirement)
      rescue => e
        msg = "Rubygems failed to parse gem: name='#{gem.name}', version='#{version_requirement}'.  Original Error:\n" +
              "  #{e.inspect}\n" +
              "If you are having problems with prerelease gems or non-numeric versions, please upgrade to the latest Rubygems."
        raise GemInstaller::GemInstallerError.new(msg)
      end
      @gem_source_index_proxy.refresh!
      @gem_source_index_proxy.search(dependency, platform_only)
    end

  end
end





