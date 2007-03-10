module GemInstaller
  # Format for "install" prompt list: "#{spec.name} #{spec.version} (#{spec.platform})"
  # Format for "uninstall" prompt list: "#{spec.name}-#{spec.version}" for ruby,  "#{spec.name}-#{spec.version}-#{spec.platform}" (gem.full_name) for binary
  class NoninteractiveChooser
    def specify_gem_spec(name, version, platform)
      @required_name = name
      @required_version = version
      @required_platform = platform
    end

    def choose(question, list)
      @question = question
      @list = list
      raise GemInstaller::GemInstallerError.new("Internal GemInstaller Error, unexpected question: '#{question}'") unless
        install_list_type? or uninstall_list_type?

      required_name_regexp = ".*?"
      required_version_regexp = ".*?"
      if uninstall_list_type? or dependent_gem?
         # match the exact name and version if it's an uninstall prompt or a dependent gem
        required_name_regexp = Regexp.escape(@required_name) if @required_name
        required_version_regexp = Regexp.escape(@required_version) if @required_version
      end
      required_list_item = "#{required_name_regexp}[\s-]{0,1}#{required_version_regexp}"
      # install list types always have the platform for each gem in parenthesis, even if it is ruby
      if (install_list_type? && @required_platform)
        required_list_item += Regexp.escape(" (#{@required_platform})")
      end
      # uninstall list types have the gem full_name, which is the platform for each gem appended after a dash, but only if it is not ruby
      if (uninstall_list_type? && @required_platform && @required_platform.to_s != GemInstaller::RubyGem.default_platform)
        required_list_item += Regexp.escape("-#{@required_platform}")
      end
      required_list_item_regex = /^#{required_list_item}$/
      list.each_with_index do |item, index|
        if (item =~ required_list_item_regex) != nil
          return item, index
        end
      end
      # if we didn't find a match, raise a descriptive error
      action = install_list_type? ? 'install' : 'uninstall'
      name = @required_name ? "#{@required_name}" : "'any name'"
      version = @required_version ? "#{@required_version}" : "'any version'"
      platform = @required_platform ? " (#{@required_platform})" : ''
      error_message = "Error: Unable to select gem from list: \"#{name} #{version}#{platform}\".  Available gems are:\n"
      list.each do |item|
        # skip last 'cancel' list entry, it's not a real gem
        next if item == list.last
        error_message += "  " + item + "\n"
      end
      raise GemInstaller::GemInstallerError.new(error_message)
    end
  
    def install_list_type?
      @question =~ /to install/
    end
  
    def uninstall_list_type?
      @question =~ /to uninstall/
    end
    
    def dependent_gem?
      # return true if it's an install prompt, and the list contains the gem for which the original install request
      # was made (in other words, it's a dependent gem, not a dependency gem)
      install_format_exact_name_match_regexp = /^#{@required_name}\s.*/
      install_list_type? and @list[0] =~ install_format_exact_name_match_regexp
    end
  
  end
end
