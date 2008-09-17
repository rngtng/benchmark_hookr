require 'test/unit'
require 'rubygems'
require 'active_support'
$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'

module BenchmarkHookr
      
  module SomeModule
    def foo; 'foo' end
    def self.bar; 'bar' end
  end

  class SomeClass
    include SomeModule
    def hello; 'hello' end
    def self.world; 'world' end
    def yielder; yield end
    def echoer(*args); args end
  end

end

