require File.dirname(__FILE__) + '/test_helper'
require 'benchmark_hookr/trackr'

module BenchmarkHookr
  class << self
    #overwrite log method, no output
    def log(msg)    
    end
  end
end

class BenchmarkHookrTest < Test::Unit::TestCase

  def setup
  end

  def test_start
    assert_nothing_raised do
      BenchmarkHookr::Trackr.start
    end
  end
  
  def test_hook
    assert_nothing_raised do
      BenchmarkHookr::Trackr.start {
        BenchmarkHookr::Trackr.hook( "hook 1")      
      }
    end
  end
  
  def test_hook_with_block
    assert_nothing_raised do
      block_executed = nil
      BenchmarkHookr::Trackr.start {
        BenchmarkHookr::Trackr.hook( "hook with block") {
          block_executed = true
        }    
      }
      assert block_executed
    end      
  end
  
end
