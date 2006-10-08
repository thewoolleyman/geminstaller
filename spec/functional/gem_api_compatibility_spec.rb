dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require 'rubygems'
require 'yaml'
require 'rubygems/doc_manager'
require 'rubygems/config_file'
require 'rubygems/cmd_manager'
require 'rubygems/gem_runner'
require 'rubygems/remote_installer'
require 'rubygems/installer'

context "rubygems api" do
  setup do
  end

  specify "should work as we expect it to" do
    # NOTE: this test is dependent upon RubyGems being installed, and write permissions (or sudo) to gem install dir
    sample_gem = "ruby-doom"
    # setup to make sure gem is not installed before test
    # TODO: how to prevent error from being written to console?
    
    if (is_gem_installed(sample_gem)) then
      uninstall_gem(sample_gem)
    end
    
    is_gem_installed(sample_gem).should_equal(false)

    Gem.manage_gems

    #Gem::GemRunner.new.run(['install',"#{sample_gem}"])
    install_gem(sample_gem)

    #gem_list_output.should_include("#{sample_gem}")
    is_gem_installed(sample_gem).should_equal(true)

    # uninstall it again after we are done
    #gem_list = Gem::GemRunner.new.run(['uninstall',"#{sample_gem}"])
    uninstall_gem(sample_gem)
    is_gem_installed(sample_gem).should_equal(false)
  end
  
  def is_gem_installed(gem_name)
    gems = Gem::cache.refresh!
    gems = Gem::cache.search(/.*#{gem_name}$/)
    gems.each do |gem|
      return true if gem.name == gem_name
    end
    return false
  end

  def uninstall_gem(gem_name)
    run_gem_command('uninstall',gem_name)
  end

  def install_gem(gem_name)
    run_gem_command('install',gem_name)
  end

  def run_gem_command(gem_command,gem_name)
    Gem::GemRunner.new.run([gem_command,"#{gem_name}"])
  end
end
