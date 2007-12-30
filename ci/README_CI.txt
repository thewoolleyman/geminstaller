Use these steps to run GemInstaller under CruiseControl.rb:

* Create project with name 'geminstaller_using_rubygems_x-y-z', where 'x-y-z' is the version of RubyGems to test against.

* Ensure that the following settings are in ~/.cruise/site_config.rb:

Configuration.serialize_builds = true
 
ActionMailer::Base.smtp_settings = {
  :address =>        "smtp.gmail.com",
  :port =>           587,
  :domain =>         "thewoolleyweb.com",
  :authentication => :plain,
  :user_name =>      "thewoolleyweb.smtp",
  :password =>       "????"
}