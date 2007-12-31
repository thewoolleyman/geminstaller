module GemInstaller
  class GemSpecManager
    attr_writer :source_index_search_adapter, :valid_platform_selector, :output_filter

    def is_gem_installed?(gem)
      return local_matching_gems(gem).size > 0
    end
    
    def all_local_gems
      all_local_specs = @source_index_search_adapter.all_local_specs
      return [] unless all_local_specs
      all_local_gems = all_local_specs.collect do |spec|
        gem = GemInstaller::RubyGem.new(spec.name, :version  => spec.version.version)
      end
      return all_local_gems
    end
    
    def local_matching_gems(gem, exact_platform_match = true)
      found_gem_specs = @source_index_search_adapter.search(gem,gem.version)
      return [] unless found_gem_specs

      if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
        found_gem_specs = found_gem_specs.select do |gem_spec|
          valid_platforms = @valid_platform_selector.select(gem.platform, exact_platform_match)
          valid_platforms.include?(gem_spec.platform)
        end
      else
        # TODO: this is a hack because source_index#search doesn't allow specification of platform
        if exact_platform_match
          found_gem_specs = found_gem_specs.delete_if do |spec|
            !spec_platform_matches?(spec, gem.platform)
          end
        end
      end
      matching_gems = found_gem_specs.map do |gem_spec|
        GemInstaller::RubyGem.new(gem_spec.name, {:version => gem_spec.version.version, :platform => gem_spec.platform })
      end
      return matching_gems
    end

    def spec_platform_matches?(spec, platform)
      spec_platform = Gem::Platform.new(spec.platform)
      if spec_platform.is_a?(String)
        return spec_platform == platform
      end
      return spec_platform =~ platform
    end
  end
end





