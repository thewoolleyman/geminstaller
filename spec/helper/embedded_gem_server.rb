module GemInstaller
  class EmbeddedGemServer
    include GemInstaller::SpecUtils
    @@gem_server_pid = nil
    def self.start
      return if @@gem_server_pid
      print "Starting embedded gem server at #{embedded_gem_dir}...\n"
      Gem.clear_paths
      cmd_args = "--dir=#{embedded_gem_dir} --port=#{embedded_gem_server_port}"
      if windows?
        server_cmd = (RUBYGEMS_VERSION_CHECKER.matches?('<= 0.9.4') ? 'gem_server.bat' : 'gem.bat server')
        io_handles_and_pid = Open4.popen4("#{rubygems_bin_dir}/#{server_cmd} #{cmd_args} --daemon",'b',true)
        pid = io_handles_and_pid[3]
        @@gem_server_pid = pid
      else
        server_cmd = (RUBYGEMS_VERSION_CHECKER.matches?('<= 0.9.4') ? 'gem_server' : 'gem server')
        # Don't daemonize, it spawns a child process that I don't know how to kill.  There's an error
        # in the 0.9.5 daemon option anyway.  Just dump everything to /dev/null (but not while I'm still fixing against rubygems 1.0.0)
        gem_server_process = IO.popen("#{ruby_cmd} #{rubygems_bin_dir}/#{server_cmd} #{cmd_args}")
        @@gem_server_pid = gem_server_process.pid
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
        if windows?
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