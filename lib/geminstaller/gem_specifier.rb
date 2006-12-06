module GemInstaller
  class GemSpecifier
    attr_writer :gem_source_index_proxy
    
    def specify!(gem)
      gem.platform = Gem::Platform::RUBY if gem.platform == nil
      gem_name_regexp = /^#{Regexp.escape(gem.name)}$/
      @gem_source_index_proxy.refresh!
      specs = @gem_source_index_proxy.search gem_name_regexp, gem.version
      specs = specs.sort_by { |spec| spec.version }.reverse
      specs.reject! { |spec|
        return false if (spec.platform.nil? || spec.platform==Gem::Platform::RUBY) && gem.platform==Gem::Platform::RUBY
        return false if spec.platform==gem.platform
        return true 
      }
      
      if specs.size == 0
        raise GemInstaller::GemInstallerError.new("Error: No gems matched the spec: #{gem.name} #{gem.version} (#{gem.platform}).\n")
      end

      # sanity check, all remaining specs should be the same name and platform (only differing in version)
      specs.each do |spec|
        if gem.name != selected_spec.name
          raise GemInstaller::GemInstallerError.new("Error: Gem name did not have an exact match, #{gem.name} should not have matched #{selected_spec.name}.\n")
        end
        if gem.platform != selected_spec.platform
          raise GemInstaller::GemInstallerError.new("Error: Gem platform did not have an exact match, #{gem.platform} should not have matched #{selected_spec.platform}.\n")
        end
      end

      # select the highest version      
      selected_spec = specs.first

      gem.version = selected_spec.version
      gem.platform = selected_spec.platform
    end
  end
end
