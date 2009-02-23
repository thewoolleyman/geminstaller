dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/geminstaller/requires.rb")

module GemInstaller
  def self.install(args = [], geminstaller_executable = nil)
    args_copy = args.dup
    args_copy = args_copy.split(' ') unless args.respond_to? :join
    # recursively call script with sudo, if --sudo option is specified
    if platform_supports_sudo? and (args_copy.include?("-s") or args_copy.include?("--sudo"))
      result = reinvoke_with_sudo(args_copy, geminstaller_executable)
      if result != 0 and (args_copy.include?("-e") or args_copy.include?("--exceptions"))
        message = "Error: GemInstaller failed while being invoked with --sudo option.  See prior output for error, and use '--geminstaller-output=all --rubygems-output=all' options to get more details."
        raise GemInstaller::GemInstallerError.new(message)
      end
      return result
    else
      app = create_application(args_copy)
      app.install
    end
  end
  
  def self.run(args = [], geminstaller_executable = nil)
    # run is now an alias for install
    install(args, geminstaller_executable)
  end
  
  def self.autogem(args = [])
    args_copy = args.dup
    args_copy = args_copy.split(' ') unless args.respond_to? :join
    # TODO: should explicitly remove all args not applicable to autogem (anything but config, silent, and geminstaller_output)
    args_without_sudo = strip_sudo(args_copy)
    app = create_application(args_without_sudo)
    app.autogem
  end

  def self.version
    "0.5.1"
  end

  def self.create_application(args = [], registry = nil)
    registry ||= create_registry
    app = registry.app
    app.args = args
    app
  end
  
  def self.create_registry
    GemInstaller::Registry.new
  end
  
  def self.parse_config_paths(config_paths)
    return nil unless config_paths
    return config_paths unless config_paths.respond_to? :join
    return config_paths.join(',')
  end
  
  def self.platform_supports_sudo?
    return true unless RUBY_PLATFORM =~ /mswin/
    return false
  end
  
  def self.reinvoke_with_sudo(args, geminstaller_executable)
    # Sudo support is a hack, better to use other alternatives.
    geminstaller_executable ||= find_geminstaller_executable
    args_without_sudo = strip_sudo(args)
    args_without_sudo << '--redirect-stderr-to-stdout'
    cmd = "sudo ruby #{geminstaller_executable} #{args_without_sudo.join(' ')}"
    # TODO: this eats any output.  There currently is no standard way to get a return code AND stdin AND stdout.
    # Some non-standard packages like Open4 handle this, but not synchronously.  The Simplest Thing That Could
    # Possibly Work is to have a command line option which will cause all stderr output to be redirected to stdout.
    result = system(cmd)
    return 1 unless result
    return $?.exitstatus
  end
  
  def self.strip_sudo(args)
    return args.reject {|arg| arg == "-s" || arg == "--sudo"}
  end
  
  def self.find_geminstaller_executable
    possible_locations = [
      'ruby -S geminstaller',
      'ruby /usr/local/bin/geminstaller',
      'ruby /usr/bin/geminstaller',
      'ruby ./bin/geminstaller'
      ]
    path_key = 'geminstaller_exec_path='
    possible_locations.each do |possible_location|
      cmd = "#{possible_location} --geminstaller-exec-path"

      $stderr_backup = $stderr.dup
      $stderr.reopen("/dev/null", "w")
      io = IO.popen(cmd)
      $stderr.reopen($stderr_backup)
      STDERR.reopen($stderr_backup) # Why are these not the same?  It is an old question: http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/47596
      output = io.read
      next unless output =~ /#{path_key}/
      path = output.sub(path_key,'')
      return path
    end
    raise GemInstaller::GemInstallerError.new("Error: Unable to locate the geminstaller executable.  Specify it explicitly, or don't use the sudo option.")
  end
end