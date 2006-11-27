# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/geminstaller.rb'

Hoe.new('geminstaller', GemInstaller::Runner::VERSION) do |p|
  p.rubyforge_name = 'geminstaller'
  p.summary = 'Automatically installs RubyGems required by your project.  (TODO: can this description automatically be read from README.txt?)'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
end

# vim: syntax=Ruby
