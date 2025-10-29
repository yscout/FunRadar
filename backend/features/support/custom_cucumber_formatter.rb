# Custom Cucumber formatter that shows percentage statistics
require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    class CustomProgress < Progress
      def initialize(config)
        super
        @total = 0
        @passed = 0
        @failed = 0
        @pending = 0
        @skipped = 0
      end

      def on_test_case_finished(event)
        super
        @total += 1
        case event.result
        when Cucumber::Core::Test::Result::Passed
          @passed += 1
        when Cucumber::Core::Test::Result::Failed
          @failed += 1
        when Cucumber::Core::Test::Result::Pending
          @pending += 1
        when Cucumber::Core::Test::Result::Skipped, Cucumber::Core::Test::Result::Undefined
          @skipped += 1
        end
      end

      def on_test_run_finished(event)
        super
        
        percentage = @total > 0 ? (@passed.to_f / @total * 100).round(2) : 0
        
        @io.puts "\n"
        @io.puts "=" * 80
        @io.puts "Scenario Results: #{@passed}/#{@total} passed (#{percentage}%)"
        @io.puts "=" * 80
      end
    end
  end
end

