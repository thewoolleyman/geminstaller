# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/geminstaller.rb'

Hoe.new('geminstaller', GemInstaller.version) do |p|
  p.author = 'Chad Woolley'
  p.rubyforge_name = 'geminstaller'
  p.summary = p.paragraphs_of('README.txt', 1).first.split(/\n/)[2]
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ["needle", ">= 1.3.0"]
end

# vim: syntax=Ruby
