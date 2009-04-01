GemInstaller
    by Chad Woolley
    http://geminstaller.rubyforge.org
    http://thewoolleyweb.lighthouseapp.com/projects/11580-geminstaller

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
* Solve world hunger, prevent the global energy crisis, and wash your socks.

== SYNOPSYS:

Automated Gem installation, activation, and much more!

=== Bugs/Patches

http://thewoolleyweb.lighthouseapp.com/projects/11580-geminstaller

=== Quick Start:

See http://geminstaller.rubyforge.org/documentation/index.html

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
