module GemInstaller
  class VersionSpecifier
    # NOTE: available_versions should be sorted in descending order (highest versions first)
    # This method will return the first matching version
    def specify(version_requirement, available_versions, gem_name = nil)
      rubygems_version_requirement = GemInstaller::REQUIREMENT_CLASS.new [version_requirement]
      if available_versions.respond_to? :to_str
        available_versions = available_versions.split(', ')
      end
      available_versions.each do |available_version_string|
        available_version = Gem::Version.new(available_version_string)
        if rubygems_version_requirement.satisfied_by?(available_version)
          return available_version.to_s
        end
      end
      gem_name_msg = ''
      if gem_name
        gem_name_msg = "for gem '#{gem_name}' "
      end
      error_msg = "The specified version requirement '#{version_requirement}' #{gem_name_msg}is not met by any of the available versions: #{available_versions.join(', ')}."
      raise GemInstaller::GemInstallerError.new(error_msg)
    end
  end
end
