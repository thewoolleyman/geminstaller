module GemInstaller
  class RubyGemsVersionChecker
    def matches?(version_spec, options = {})
      version_spec = [version_spec] unless version_spec.kind_of?(Array)
      rubygems_version = options[:rubygems_version] ||= Gem::RubyGemsVersion
      Gem::Version::Requirement.new(version_spec).satisfied_by?(Gem::Version.new(rubygems_version))
    end
  end
end

RUBYGEMS_VERSION_CHECKER = GemInstaller::RubyGemsVersionChecker.new
