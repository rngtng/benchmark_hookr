require 'dispatcher'
require 'benchmark_hookr/trackr'

module BenchmarkHookr
  module ObjectMixIn
    def hook(*msg, &block) # :doc:
      BenchmarkHookr::Trackr.hook(*msg, &block)
    end
  end 
end

class Object
  include BenchmarkHookr::ObjectMixIn
end

#we sneak into dispatcher to display the result at the end
class ::Dispatcher
  # print reports at the end
  def dispatch_with_benchmark_hookr(*args, &block) #:nodoc:
    BenchmarkHookr::Trackr.start {
      dispatch_without_benchmark_hookr(*args, &block)
    }
    #RAILS_DEFAULT_LOGGER.flush if RAILS_DEFAULT_LOGGER.respond_to? :flush
  end
  alias_method_chain :dispatch, :benchmark_hookr
end
