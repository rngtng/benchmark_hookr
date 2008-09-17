module BenchmarkHookr
  class << self
     
    def start(&block)
      init
      hook( &block )
      summerize( @report, @report.first[:time], @report.last[:time] )
      print_report
    end

    def hook( msg = "Hook", &block)
      @current_report << hook_item( msg )

      if block
        last_report = @current_report
        @current_report = [] 
        hook( "BEGIN #{msg}" )
        block.call
        last_report.last[:block] = @current_report
        @current_report = last_report
        hook( "AFTER #{msg}" )        
      end    
    end  

    def log(msg)
      ActiveRecord::Base.logger.info(msg)
    end 

    private            
    def init
      @report = []
      @current_report = @report
    end  
      
    def hook_item( msg )
      { :msg => msg, :time => Time.now}
    end    
      
    def summerize( reports, started, finished)
      runtime = finished - started 
      reports.reverse.each do |report|
        report[:runtime]        = finished - report[:time]
        report[:percentage]     = report[:runtime] * 100 / runtime
        report[:percentage_all] = report[:runtime] * 100 / @report.first[:runtime] if @report.first[:runtime] && @report.first[:runtime] > 0 
        report[:pointtime]      = report[:time] - @report.first[:time]
        summerize( report[:block], report[:time], finished) if report[:block].any?
        finished = report[:time]
      end  
    end 

    def print_report
      log( "|--- BenchmarkHookr --------------------     Time |    Runtime | Block% |  All%" )
      print( @report.first[:block] )      
      log( "|--- Total: %10.6f seconds --------------------------------------------" % @report.first[:runtime]  )
    end
      
    def print( reports, level = 0)                 
      reports.each do |report|
        log( "#{' '*level*2}|- %-#{35-(2*level)}s %10.6f | %10.6f | %5.2f%% | %5.2f%%" % [ report[:msg], report[:pointtime], report[:runtime], report[:percentage], report[:percentage_all] ] )
        print( report[:block], level + 1) if report[:block].any?
      end         
    end

  end
end