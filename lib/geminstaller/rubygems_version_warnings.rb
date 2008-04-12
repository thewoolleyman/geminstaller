module GemInstaller
  class RubyGemsVersionWarnings
    def self.outdated_warning(options = {})
      return nil if allow_unsupported?
      return nil if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5', options)
      return "\n\n----------------------------------------------------------------\n" + 
                  "WARNING: You are using RubyGems version #{Gem::RubyGemsVersion}.\n" +
                  "You should update to RubyGems version 1.0.1 or above,\n" +
                  "because gems created for newer RubyGems versions\n" +
                  "might be incompatible.\n" +
                  "To update rubygems (recommended), use 'gem update --system'.\n" +
                  "----------------------------------------------------------------\n\n"
    end

    def self.incompatible_warning(options = {})
      return nil if allow_unsupported?
      return nil unless (
        GemInstaller::RubyGemsVersionChecker.matches?('=0.9.5', options) or
        GemInstaller::RubyGemsVersionChecker.matches?('=1.1.0', options)
      )
      return "\n\n----------------------------------------------------------------\n" + 
                  "WARNING: You are using RubyGems version #{Gem::RubyGemsVersion}.\n" +
                  "This version is known to have bugs and/or compatibility issues\n" +
                  "with GemInstaller.  Update RubyGems, or continue at your risk.\n" +
                  "To update rubygems (recommended), use 'gem update --system'.\n" +
                  "----------------------------------------------------------------\n\n"
    end

    def self.allow_unsupported?
      defined? ALLOW_UNSUPPORTED_RUBYGEMS_VERSION
    end
    
    def self.print_warnings(options = {})
      warnings = [self.outdated_warning, self.incompatible_warning].compact!
      warnings.each {|warning| print warning}
    end
  end
end