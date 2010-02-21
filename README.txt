= GemInstaller

* http://geminstaller.rubyforge.org
* http://thewoolleyweb.lighthouseapp.com/projects/11580-geminstaller
* mailto:"GemInstaller Development" <geminstaller-development@rubyforge.org>
* mailto:"Chad Woolley" <thewoolleyman@gmail.com>


== UPDATE - READ THIS

* GemInstaller is being deprecated in favor of Bundler: http://github.com/carlhuda/bundler
* There is a --bundler-export option on geminstaller to help GemInstaller users migrate to Bundler.
* This site is outdated, and will remain that way.  I'll try to keep GemInstaller working with new RubyGems releases for as long as I can, but I won't do much else.  I've also given up on testing older Rubygems versions and Windows (although they should still work, feel free to open a bug if they don't).
* Why Bundler instead of (some other tool)?  Dependency Management is a hard problem to solve properly.  Bundler does the right things.
* If you think Bundler is too complex, then you probably don't understand the problem, or have never dealt (properly) with long-term or complex dependency management issues in the real world, or just like to be contrary.  Bundler resolves your entire Gem dependency graph and freezes it in your app.  If your tool of choice doesn't do this, it is inferior.  Perhaps very usable (like GemInstaller), but still inferior.  If you have problems with Bundler, I'd recommend opening an issue: http://github.com/carlhuda/bundler/issues

== DESCRIPTION:

Automated Gem installation, activation, and much more!

== FEATURES:
  
GemInstaller provides automated installation, loading and activation of RubyGems.  It uses a simple YAML config file to:
* Automatically install the correct versions of all required gems wherever your app runs.
* Automatically ensure installed gems and versions are consistent across multiple applications, machines, platforms, and environments 
* Automatically activate correct versions of gems on the ruby load path when your app runs ('require_gem'/'gem')
* Automatically reinstall missing dependency gems (built in to RubyGems > 1.0)
* Automatically detect correct platform to install for multi-platform gems (built in to RubyGems > 1.0)
* Print YAML for "rogue gems" which are not specified in the current config, to easily bootstrap your config file, or find gems that were manually installed without GemInstaller.
* Allow for common configs to be reused across projects or environments by supporting multiple config files, including common config file snippets, and defaults with overrides.
* Allow for dynamic selection of gems, versions, and platforms to be used based on environment vars or any other logic.
* Avoid the "works on demo, breaks on production" syndrome
* Find lost socks.

== SYNOPSYS:

See Quick Start at http://geminstaller.rubyforge.org/documentation/index.html

=== Bugs/Patches

http://thewoolleyweb.lighthouseapp.com/projects/11580-geminstaller

=== Quick Start:

See http://geminstaller.rubyforge.org/documentation/index.html

== REQUIREMENTS:

* RubyGems

== INSTALL:

* [sudo] gem install geminstaller

== LICENSE:

(The MIT License)

Copyright (c) 2008 Chad Woolley

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
