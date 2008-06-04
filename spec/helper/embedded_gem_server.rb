module GemInstaller
  class EmbeddedGemServer
    include GemInstaller::SpecUtils
    @@gem_server_pid = nil
    def self.start
      return if @@gem_server_pid
      print "Starting embedded gem server at #{embedded_gem_dir}...\n"
      Gem.clear_paths
      cmd_args = "--dir=#{embedded_gem_dir} --port=#{embedded_gem_server_port} --debug"
      if windows?
        server_cmd = (GemInstaller::RubyGemsVersionChecker.matches?('<= 0.9.4') ? 'gem_server.bat' : "#{gem_cmd} server")
        @@gem_server_process = IO.popen("#{server_cmd} #{cmd_args}")
        @@gem_server_pid = @@gem_server_process.pid
      else
        server_cmd = (GemInstaller::RubyGemsVersionChecker.matches?('<= 0.9.4') ? "#{ruby_cmd} #{rubygems_bin_dir}/gem_server" : "#{gem_cmd} server")
        cmd = "#{server_cmd} #{cmd_args}"
        @@gem_server_pid, gem_server_stdin, @@gem_server_stdout, @@gem_server_stderr = Open4.open4(cmd)
        gem_server_stdin.close
      end
      print "Started embedded gem server at #{embedded_gem_dir}, pid = #{@@gem_server_pid}\n"
      trap("INT") { Process.kill(9,@@gem_server_pid); exit! }
      # TODO: avoid sleep by detecting when gem_server port comes up
      sleep 3
    end
    
    def self.embedded_gem_dir
      File.dirname(__FILE__) + "/../fixture/gems"
    end
    
    def self.stop
      stopped = false
      if @@gem_server_pid
        print "Killing embedded gem server at pid = #{@@gem_server_pid}\n"
        kill_result = Process.kill(8,@@gem_server_pid)
        unless windows?
          # uncomment to print server debug output
          # @@gem_server_stdout.each_line { |l| puts l}
          # @@gem_server_stderr.each_line { |l| puts l}
        else
          kill_result.each do |pid|
            print "  Killed pid: #{pid}\n"
          end
          print "NOTE: On windows, there is an orphaned gem_server ruby
      process left, which was a grandchild of the top-level ruby
      process which runs the tests, and a child of the cmd process
      which runs gem_server.bat.  Apparently, there's no way to kill
      this, other than using the ruby-services package, which I haven't
      done yet:
      http://rubyforge.org/tracker/index.php?func=detail&aid=8957&group_id=85&atid=412
      \n"
        end
        stopped = true
      end
      return stopped
    end
    
    def self.windows?
      RUBY_PLATFORM =~ /mswin/
    end
  end
end