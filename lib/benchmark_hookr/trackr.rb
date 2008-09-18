module BenchmarkHookr
  module Trackr
    class << self     
      def start(&block)
        init
        to_return = block.call        
        print_report
        to_return
      end

      def hook( msg = "Hook", &block)
        @current_report << hook_item( msg )

        to_return = true 
        if block
          last_report = @current_report
          @current_report = [] 
          hook( "BLOCK BEGIN #{msg}" ) #virtual hook
          to_return = block.call
          last_report.last[:block] = @current_report
          @current_report = last_report
          hook( "AFTER #{msg}" )        
        end    
        to_return
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

      def print_report
        summerize( @report, @report.first[:time], @report.last[:time] )
        log( "\n\e[1m|--- BenchmarkHookr --------------------   Time   |   All% |  Runtimes (Block%) ---------------------\e[0m" )
        print( @report )      
        log( "\e[1m|--- Total: %10.6f seconds -----------------------------------------------------------------------\e[0m\n" % (@report.last[:time]-@report.first[:time])  )
      end

      def summerize( reports, started, finished)
        runtime = finished - started 
        reports.reverse.each do |report|
          report[:runtime]        = finished - report[:time]
          report[:percentage]     = report[:runtime] * 100 / runtime
          report[:percentage_all] = report[:runtime] * 100 / (@report.last[:time]-@report.first[:time])
          report[:pointtime]      = report[:time] - @report.first[:time]
          summerize( report[:block], report[:time], finished) if report[:block]
          finished = report[:time]
        end  
      end 

      #we use ..[:block][1..-1] here as the first entry of a block is always a virtual hook 
      # we don't want to show in extra line. instead, we show time next to it
      def print( reports, level = 0)
        reports.each do |report|
          blocktime = (report[:block].to_a.size > 1) ? " -#{f_run(report[:block].first)}" : ''          
          s = '         |           '
          log( f_s(report[:msg], level) + " " + f_t(report[:pointtime]) + " | " + f_p(report[:percentage_all]) +" |#{s*level}#{f_run(report)}#{blocktime}\e[0m" )
          print( report[:block][1..-1], level + 1) if report[:block]
        end         
      end
      
      def f_run(report)
       "#{f_t(report[:runtime])} (#{f_p(report[:percentage])})"
      end
      
      def f_s( string, level )        
        "#{' '*(level*3)}|- %-#{35-(3*level)}s" % string
      end
      
      def f_t( number )
        color = number > 10 ? "\e[31m" : ""
        "#{color}%10.6f\e[0m" % number
      end  
      
      def f_p( number )
        color = number > 10 ? "\e[31m" : ""
        "#{color}%5.2f%%\e[0m" % number
      end  
    end
  end  
end