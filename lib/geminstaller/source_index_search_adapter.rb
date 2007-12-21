module GemInstaller
  class SourceIndexSearchAdapter
    attr_writer :gem_source_index_proxy
    
    def all_local_specs
      search_less_than_or_equal_0_9_4('',GemInstaller::RubyGem.default_version)
    end

    def search(gem, version_requirement, platform_only = false)
      if RUBYGEMS_VERSION_CHECKER.matches?('<=0.9.4')
        gem_pattern = /^#{gem.regexp_escaped_name}$/
        search_less_than_or_equal_0_9_4(gem_pattern, version_requirement)
      end
    end
    
    def search_less_than_or_equal_0_9_4(gem_pattern, version_requirement)
      @gem_source_index_proxy.refresh!
      @gem_source_index_proxy.search(gem_pattern, version_requirement)
    end
  end
end





