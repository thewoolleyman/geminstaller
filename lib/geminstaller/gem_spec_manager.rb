module GemInstaller
  class GemSpecManager
    attr_writer :gem_source_index_proxy, :output_filter

    def search(gem_pattern, version_requirement)
      @gem_source_index_proxy.refresh!
      @gem_source_index_proxy.search(gem_pattern, version_requirement)
    end
    
    def all_local_gems
      all_local_specs = search('',GemInstaller::RubyGem.default_version)
      return [] unless all_local_specs
      all_local_gems = all_local_specs.collect do |spec|
        gem = GemInstaller::RubyGem.new(spec.name, :version  => spec.version.version)
      end
      return all_local_gems
    end
    
  end
end





