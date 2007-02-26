module GemInstaller
  class EmbeddedGemServer
    @@gem_server_pid = nil
    def self.start
      return if @@gem_server_pid
      Gem.clear_paths
      gem_server_process = IO.popen("gem_server --dir=#{embedded_gem_dir} --port=#{GemInstaller::SpecUtils.embedded_gem_server_port}")
      @@gem_server_pid = gem_server_process.pid
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
        Process.kill(9,@@gem_server_pid)
        stopped = true
      end
      return stopped
    end
  end
end