module GemInstaller
  class GemSpecManager
    attr_writer :gem_source_index_proxy, :output_filter

    def search(gem_pattern, version_requirement)
      @gem_source_index_proxy.refresh!
      @gem_source_index_proxy.search(gem_pattern, version_requirement)
    end
    
  end
end





