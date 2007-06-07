module GemInstaller
  class RubyGemsVersionChecker
    def less_than?(compare_version, rubygems_version = Gem::RubyGemsVersion)
      Gem::Version::Requirement.new(["< #{compare_version}"]).satisfied_by?(Gem::Version.new(rubygems_version))
    end
  end
end
