module GemInstaller
  class GemSpecManager
    attr_writer :gem_source_index_proxy, :valid_platform_selector, :output_filter

    def search(gem_pattern, version_requirement)
      @gem_source_index_proxy.refresh!
      @gem_source_index_proxy.search(gem_pattern, version_requirement)
    end
    
    def is_gem_installed?(gem)
      return local_matching_gems(gem).size > 0
    end
    
    def all_local_gems
      all_local_specs = search('',GemInstaller::RubyGem.default_version)
      return [] unless all_local_specs
      all_local_gems = all_local_specs.collect do |spec|
        gem = GemInstaller::RubyGem.new(spec.name, :version  => spec.version.version)
      end
      return all_local_gems
    end
    
    def local_matching_gems(gem, exact_platform_match = true)
      gem_name_regexp = /^#{gem.regexp_escaped_name}$/
      found_gem_specs = search(gem_name_regexp,gem.version)
      return [] unless found_gem_specs
      matching_gem_specs = found_gem_specs.select do |gem_spec|
        valid_platforms = @valid_platform_selector.select(gem.platform, exact_platform_match)
        valid_platforms.include?(gem_spec.platform)
      end
      matching_gems = matching_gem_specs.map do |gem_spec|
        GemInstaller::RubyGem.new(gem_spec.name, {:version => gem_spec.version.version, :platform => gem_spec.platform })
      end
      return matching_gems
    end
  end
end




