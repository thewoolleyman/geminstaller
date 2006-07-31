# This code was taken from http://www.onestepback.org/articles/depinj/ci/class_intercepter_rb.html,
# which part of Jim Weirich's presentation on Dependency Injection: http://www.onestepback.org/articles/depinj/
class ClassProxy
  attr_accessor :proxied_class
  def initialize(default_class)
    @proxied_class = default_class
  end
  def new(*args, &block)
    @proxied_class.new(*args, &block)
  end
end

class Class
  def use_class(class_name, class_ref)
    proxy = const_get(class_name)
    unless ClassProxy === proxy
      self.const_set(class_name, ClassProxy.new(proxy))
      proxy = const_get(class_name)
    end
    if ! block_given?
      proxy.proxied_class = class_ref
    else
      old_proxied = proxy.proxied_class
      proxy.proxied_class = class_ref
      begin
	      yield
      ensure
	      proxy.proxied_class = old_proxied
      end
    end
  end
end