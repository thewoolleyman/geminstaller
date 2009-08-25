module GemInstaller
  class ExactMatchListCommand < LIST_COMMAND_CLASS
    def execute
      string = get_one_optional_argument || ''
      # This overrides the default RubyGems ListCommand behavior of doing a wildcard match.  This caused problems
      # when some gems (ActiveRecord-JDBC) caused exceptions during a remote list, causing a remote list
      # of other gems (activerecord) to fail as well
      options[:name] = /^#{string}$/
      # Do a little metaprogramming magic to avoid calling the problematic execute method on the ListCommand
      # superclass, and instead directly call the method on the QueryCommand grandparent 'supersuperclass'
      unbound_execute_method = QUERY_COMMAND_CLASS.instance_method(:execute)
      bound_execute_method = unbound_execute_method.bind(self)
      bound_execute_method.call
    end
  end
end