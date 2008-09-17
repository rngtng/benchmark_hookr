require 'dispatcher'
# The special :request benchmark. This tries to encompass everything that runs
# to handle a request.

#class Object
#  def self.hook(*msg, &block) # :doc:
#    BenchmarkHookr.hook(*msg, &block)
#  end
#    
#  def hook(*msg, &block) # :doc:
#    BenchmarkHookr.hook(*msg, &block)
#  end
#end

#this is kind of dogy, how to inclue hook into every class/object?
class ActionController::Base
  def self.hook(*msg, &block) # :doc:
    BenchmarkHookr.hook(*msg, &block)
  end
    
  def hook(*msg, &block) # :doc:
    BenchmarkHookr.hook(*msg, &block)
  end
end

class ActionView::Base
  def self.hook(*msg, &block) # :doc:
    BenchmarkHookr.hook(*msg, &block)
  end
    
  def hook(*msg, &block) # :doc:
    BenchmarkHookr.hook(*msg, &block)
  end
end

class ActiveRecord::Base
  def self.hook(*msg, &block) # :doc:
    BenchmarkHookr.hook(*msg, &block)
  end
    
  def hook(*msg, &block) # :doc:
    BenchmarkHookr.hook(*msg, &block)
  end  
end

#################################################

#we sneak into dispatcher to display the result at the end
class ::Dispatcher
  # print reports at the end
  def dispatch_with_benchmark_hookr(*args, &block) #:nodoc:
    r = nil
    BenchmarkHookr.start {
      r = dispatch_without_benchmark_hookr(*args, &block)
    }
    RAILS_DEFAULT_LOGGER.flush if RAILS_DEFAULT_LOGGER.respond_to? :flush
    r
  end
  alias_method_chain :dispatch, :benchmark_hookr
end