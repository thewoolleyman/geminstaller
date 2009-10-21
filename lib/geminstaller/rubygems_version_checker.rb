module GemInstaller
  class RubyGemsVersionChecker
    def self.matches?(version_spec, options = {})
      version_spec = [version_spec] unless version_spec.kind_of?(Array)
      # TODO: if rubygems has already been initialized before GemInstaller overrides the rubygems version,
      # (for example, by running rspec), then Gem::RubyGemsVersion could be initialized to the incorrect
      # system-rubygems version instead of the geminstaller-overridden version.  Need to figure out how
      # to re-parse 'rubygems/rubygems_version' and let it redefine 'Gem::RubyGemsVersion'
      rubygems_version = options[:rubygems_version] ||= Gem::RubyGemsVersion
      
      # Manually check here in addition to backward_compatibility.rb, to avoid circular dependency
      if defined?(Gem::Requirement)
        requirement_class = Gem::Requirement
      else
        requirement_class = Gem::Version::Requirement
      end
      
      requirement_class.new(version_spec).satisfied_by?(Gem::Version.new(rubygems_version))
    end
  end
end