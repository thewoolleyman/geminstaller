module GemInstaller
  class EmbeddedGemServer
    @@gem_server_pid = nil
    def self.start
      return if @@gem_server_pid
      Gem.clear_paths
      cmd_args = "--dir=#{embedded_gem_dir} --port=#{GemInstaller::SpecUtils.embedded_gem_server_port}"
      if windows?
        io_handles_and_pid = Open4.popen4("gem_server.bat #{cmd_args}",'b',true)
        pid = io_handles_and_pid[3]
        @@gem_server_pid = pid
      else
        gem_server_process = IO.popen("gem_server #{cmd_args}")
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
        kill_result = Process.kill(1,@@gem_server_pid)
        if windows?
          kill_result.each do |pid|
            print "  Killed pid: #{pid}\n"
          end
          print "NOTE: On windows, there is an orphaned gem_server ruby
      process left, which was a grandchild of the top-level ruby
      process which runs the tests, and a child of the cmd process
      which runs gem_server.bat.  I can't figure out how to make
      it die.  Luckily, there only seems to be one alive at any
      given time, not an additional one for each test run, and this
      one dies when the console used to run the tests is closed.\n\n"
         print "WARNING: the windows tests are currently only passing
      when run via 'rake test/test_all.rb.  They fail when run via
      'rake test'\n"
        end
        stopped = true
      end
      return stopped
    end
    
    def self.windows?
      RUBY_PLATFORM.index('mswin')
    end
  end
end