module GemInstaller
  class VersionSpecifier
    # NOTE: available_versions should be sorted in descending order (highest versions first)
    # This method will return the first matching version
    def specify(version_requirement, available_versions)
      rubygems_version_requirement = Gem::Version::Requirement.new [version_requirement]
      if available_versions.respond_to? :to_str
        available_versions = available_versions.split(', ')
      end
      available_versions.each do |available_version_string|
        available_version = Gem::Version.new(available_version_string)
        if rubygems_version_requirement.satisfied_by?(available_version)
          return available_version.to_s
        end
      end
    end
  end
end
