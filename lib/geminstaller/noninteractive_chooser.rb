module GemInstaller
  # Format for "install" prompt list: "#{spec.name} #{spec.version} (#{spec.platform})"
  # Format for "uninstall" prompt list: "#{spec.name}-#{spec.version}" for ruby,  "#{spec.name}-#{spec.version}-#{spec.platform}" (gem.full_name) for binary
  class NoninteractiveChooser
    attr_writer :gem_source_index_proxy
    attr_writer :list_type
    
    def specify_exact_gem_spec(name, version, platform)
      @required_name = name
      @required_version = version
      @required_platform = platform
    end
    def choose(list)
      raise GemInstaller::GemInstallerError.new("Error: list_type must be specified for NoninteractiveChooser.") unless @list_type
      required_list_item = "#{Regexp.escape(@required_name)}.#{Regexp.escape(@required_version)}"
      # install list types always have the platform for each gem in parenthesis, even if it is ruby
      if (@list_type == :install_list_type && @required_platform)
        required_list_item += Regexp.escape(" (#{@required_platform})")
      end
      # uninstall list types have the gem full_name, which is the platform for each gem appended after a dash, but only if it is not ruby
      if (@list_type == :uninstall_list_type && @required_platform && @required_platform.to_s != GemInstaller::GemSpecifier.default_platform)
        required_list_item += Regexp.escape("-#{@required_platform}")
      end
      required_list_item_regex = /^#{required_list_item}$/
      list.each_with_index do |item, index|
        if (item =~ required_list_item_regex) != nil
          return item, index
        end
      end
      return nil, nil
    end
  end
end
