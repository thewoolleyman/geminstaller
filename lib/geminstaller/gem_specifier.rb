module GemInstaller
  class GemSpecifier
    attr_writer :gem_source_index_proxy
    
    def self.default_platform
      Gem::Platform::RUBY
    end
    
    def specify!(gem)
      gem.platform = GemInstaller::GemSpecifier.default_platform if gem.platform == nil
      gem_name_regexp = /^#{Regexp.escape(gem.name)}$/
      @gem_source_index_proxy.refresh!
      specs = @gem_source_index_proxy.search gem_name_regexp, gem.version
      specs = specs.sort_by { |spec| spec.version }.reverse
      # reject specs that do not match the specified gem platform
      specs.reject! { |spec|
        reject = true
        reject = false if (spec.platform.nil? || spec.platform==Gem::Platform::RUBY) && gem.platform==Gem::Platform::RUBY
        reject = false if spec.platform==gem.platform
        reject 
      }
      
      if specs.size == 0
        raise GemInstaller::GemInstallerError.new("Error: No gems matched the spec: #{gem.name} #{gem.version} (#{gem.platform}).\n")
      end

      # sanity check, all remaining specs should be the same name and platform (only differing in version)
      last_version = nil
      specs.each do |spec|
        if gem.name != spec.name
          raise GemInstaller::GemInstallerError.new("Error: Gem name did not have an exact match, #{gem.name} should not have matched #{spec.name}.\n")
        end
        if gem.platform != spec.platform
          raise GemInstaller::GemInstallerError.new("Error: Gem platform did not have an exact match, #{gem.platform} should not have matched #{spec.platform}.\n")
        end
        if last_version == spec.version 
          raise GemInstaller::GemInstallerError.new("Error: More than one gem matched, name=#{gem.name}, version=#{spec.version}, platform=#{gem.platform}.\n")
        end
        last_version = spec.version
      end

      # select the highest version      
      selected_spec = specs.first

      gem.version = selected_spec.version
      gem.platform = selected_spec.platform
    end
  end
end
