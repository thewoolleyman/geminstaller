module GemInstaller
  class GemSourceIndexProxy
    def gem_source_index=(gem_source_index)
      @gem_source_index = gem_source_index
    end

    def refresh!
      @gem_source_index.refresh!
    end

    # TODO: How can I avoid copying the default version_requirement value from the Gem source?
    def search(gem_pattern, version_requirement=Gem::Version::Requirement.new(">= 0"))
      @gem_source_index.search(gem_pattern, version_requirement)
    end
  end
end





