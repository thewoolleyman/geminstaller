module GemInstaller
  # Format for "install" prompt list: "#{spec.name} #{spec.version} (#{spec.platform})"
  # Format for "uninstall" prompt list: "#{spec.name}-#{spec.version}" for ruby,  "#{spec.name}-#{spec.version}-#{spec.platform}" (gem.full_name) for binary
  class NoninteractiveChooser
    def initialize
      @question = nil
    end
    
    def choose(question, list, dependent_gem_name, dependent_gem_version, valid_platforms)
      @question = question
      @list = list
      @dependent_gem_name = dependent_gem_name
      @dependent_gem_version = dependent_gem_version
      @valid_platforms = valid_platforms
      raise GemInstaller::GemInstallerError.new("Internal GemInstaller Error, unexpected choice prompt question: '#{question}'") unless
        install_list_type? or uninstall_list_type?

      raise GemInstaller::GemInstallerError.new("valid_platforms must be passed as an array.") unless 
        valid_platforms.respond_to? :shift

      raise GemInstaller::GemInstallerError.new("Internal GemInstaller Error, multiple platforms cannot be specified for an uninstall prompt") if
        uninstall_list_type? and valid_platforms.size > 1

      index = nil
      valid_platforms.each do |platform|
        index = find_matching_line(platform)
        break if index 
      end
      
      return @list[index], index if index
      
      # if we didn't find a match, raise a descriptive error
      action = install_list_type? ? 'install' : 'uninstall'
      name = @dependent_gem_name ? "#{@dependent_gem_name}" : "'any name'"
      version = @dependent_gem_version ? "#{@dependent_gem_version}" : "'any version'"
      platform = @valid_platforms ? " (#{@valid_platforms.join(' or ')})" : ''
      error_message = "Error: Unable to select gem from list: \"#{name} #{version}#{platform}\".  Available gems are:\n"
      list.each do |item|
        # skip last 'cancel' list entry, it's not a real gem
        next if item == list.last
        error_message += "  " + item + "\n"
      end
      raise GemInstaller::GemInstallerError.new(error_message)
    end
    
    def find_matching_line(platform)
      required_list_item_regexp = required_name_and_version_regexp + required_platform_regexp(platform)
      line_selector = /^#{required_list_item_regexp}$/
      @list.each_with_index do |item, index|
        if item =~ line_selector
          return index
        end
      end
      return nil
    end
    
    def required_name_and_version_regexp
      required_name_regexp = ".*?"
      required_version_regexp = ".*?"
      if uninstall_list_type? or dependent_gem?
         # match the exact name and version if it's an uninstall prompt or a dependent gem
        required_name_regexp = Regexp.escape(@dependent_gem_name) if @dependent_gem_name
        required_version_regexp = Regexp.escape(@dependent_gem_version) if @dependent_gem_version
      end
      "#{required_name_regexp}[\s-]{0,1}#{required_version_regexp}"
    end

    def required_platform_regexp(platform_to_match)
      return "" unless platform_to_match
      required_platform = ""
      escaped_platform_to_match = Regexp.escape(platform_to_match)
      platform_regex = nil
      if dependent_gem?
        # do an exact match on the platform if this is the dependent gem
        platform_regex = "#{escaped_platform_to_match}"
      else
        # do a wildcard match on the platform if it's not the dependent gem
        platform_regex = ".*?#{escaped_platform_to_match}.*?"
      end
      # install list types always have the platform for each gem in parenthesis, even if it is ruby
      if (install_list_type?)
        required_platform = " \\(#{platform_regex}\\)"
      end
      # uninstall list types have the gem full_name, which is the platform for each gem appended after a dash, but only if it is not ruby
      if (uninstall_list_type? && platform_to_match.to_s != GemInstaller::RubyGem.default_platform)
        required_platform = "-.*?#{platform_regex}.*?"
      end
      required_platform
    end
    
    def install_list_type?(question = @question)
      question =~ /to install/
    end
  
    def uninstall_list_type?(question = @question)
      question =~ /to uninstall/
    end
    
    def dependent_gem?(dependent_gem_name = @dependent_gem_name, list = @list)
      # return true if it's an install prompt, and the list contains the gem for which the original install request
      # was made (in other words, it's a dependent gem, not a dependency gem)
      install_format_exact_name_match_regexp = /^#{dependent_gem_name}\s.*/
      install_list_type? and list[0] =~ install_format_exact_name_match_regexp
    end
  
  end
end
