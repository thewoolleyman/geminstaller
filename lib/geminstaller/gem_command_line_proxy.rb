module GemInstaller
  class GemCommandLineProxy
    def run(args)
      args_string = args.join(" ")
      output = `gem #{args_string} 2>&1`
      return_value = $?
      lines = output.split("\n")
      # return value is always zero on windows (from gem.bat), so we have to resort to parsing the output
      error_in_output = false
      lines.each do |line|
        if line.match(/^ERROR.*/)
          error_in_output = true
          break
        end
      end
      if (return_value != 0 or error_in_output)
        error_message = "Error: gem command failed.  Command was 'gem #{args_string}', return value was '#{return_value}'.  Output was:\n"
        lines.each do |line| 
          error_message += '  ' + line + '\n'
        end
        raise GemInstaller::GemInstallerError.new(error_message)
      end
      return lines
    end
  end
end





