#!/usr/bin/env ruby

gem_src_dir = "#{File.expand_path(File.dirname(__FILE__))}/gems/gems"
p "#{gem_src_dir}"

Dir.foreach("#{gem_src_dir}") do |gemdir|
  next if %w(. .. .svn).detect {|x| x == gemdir}
  system "cd #{gem_src_dir}/#{gemdir} && rake gem && echo `pwd` && cp pkg/*.gem ../../cache && rm -rf pkg && cd #{gem_src_dir}/../.."
end

