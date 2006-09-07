dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require 'rubygems'
require 'yaml'
require 'rubygems/remote_installer'
require 'rubygems/installer'

module Gem
  class StreamUI
    class << self
      attr_accessor :outs
    end
    def outs
      self.class.outs
    end
  end
end


context "rubygems api" do
  setup do
  end

  specify "should work as we expect it to" do
    # NOTE: this test is dependent upon RubyGems being installed, and write permissions (or sudo) to gem install dir
    sample_gem = "ruby-doom"
    # setup to make sure gem is not installed before test
    # TODO: how to prevent error from being written to console?

    Gem.manage_gems

    Gem::GemRunner.new.run(['install',"#{sample_gem}"])

    # check gem lst to make sure gem is installed
    buff = ""

    def buff.write(str)
      self << str
    end

    outs = Gem::StreamUI.outs
    original_outs = outs

    outs = buff

    # gem list only writes to stdout, so we must capture it
    Gem::GemRunner.new.run(['list'])

    # redirect stdout back to original stdout
    Gem::StreamUI.outs = original_outs

    # write contents of buff to stdout
    gem_list_output = buff


    p "gem_list_output = #{gem_list_output.inspect}"
    #gem_list_output.should_include("#{sample_gem}")

    # uninstall it again after we are done
    gem_list = Gem::GemRunner.new.run(['uninstall',"#{sample_gem}"])
  end

  def execute(cmd)
    exec = open("|" + cmd)
    retbuf = exec.read
    exec.close
    return retbuf
  end

end
