module GemInstaller
  class GemSourceIndexProxy
    def gem_source_index=(gem_source_index)
      @gem_source_index = gem_source_index
    end

    def refresh!
      @gem_source_index.refresh!
    end

    # NOTE: We will require an exact version requirement, rather than the standard default Gem version_requirement of ">= 0"
    #       GemInstaller has it's own default defined elsewhere
    def search(gem_pattern, version_requirement)
      @gem_source_index.search(gem_pattern, version_requirement)
    end
  end
end





