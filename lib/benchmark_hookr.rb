require 'dispatcher'
require 'benchmark_hookr/trackr'

module BenchmarkHookr
  module ObjectMixIn
    def hook(*arg, &block) # :doc:
      BenchmarkHookr::Trackr.hook(*arg, &block)
    end
    
    def cmethod_hook(method, name = nil)
      method_hook(method, name, true)
    end  

    def method_hook(method, name = nil, klass = false)
      name ||= "#{self.to_s}##{method}"
      self.class_eval <<-EOL, __FILE__, __LINE__
        #{"class << self" if klass}
        def #{method}_with_benchmark_hookr(*args, &block)
          BenchmarkHookr::Trackr.hook("#{name}") {#{method}_without_benchmark_hookr(*args, &block)}
        end      
        alias_method_chain :#{method}, :benchmark_hookr
        #{"end" if klass}
      EOL
    end
    
  end 
end

class Object
  include BenchmarkHookr::ObjectMixIn
end

#we sneak into dispatcher to display the result at the end
class ::Dispatcher
  # print reports at the end
  def dispatch_with_benchmark_hookr_start(*args, &block) #:nodoc:
    BenchmarkHookr::Trackr.start {
      dispatch_without_benchmark_hookr_start(*args, &block)
    }
    #RAILS_DEFAULT_LOGGER.flush if RAILS_DEFAULT_LOGGER.respond_to? :flush
  end
  alias_method_chain :dispatch, :benchmark_hookr_start
end

##  # Processing the action itself (calling the controller method)
##  # This is what Rails' default benchmarks claim is the response time.
##  ActionController::Base.method_hook(:perform_action)
##  
##  # Session management is normally small, although sometimes it's still a
##  # significant percentage.
##  CGI::Session.method_hook(:initialize)
##  ActionController::Base.method_hook(:close_session)
##  
##  # Controller filters
##  ActionController::Filters::InstanceMethods.method_hook(:run_before_filters)
##  ActionController::Filters::InstanceMethods.method_hook(:run_after_filters)
##  
##  # The real cost of database access should include query construction.
##  # Hence why we try and watch the core finder. More watches might be added
##  # to this group to form a more complete picture of database access. The
##  # question is simply which methods bypass find().
##  ActiveRecord::Base.cmethod_hook(:find)
##  
##  # And yes, it's still important to know how much time is spent rendering.
##  ActionController::Base.method_hook(:render)