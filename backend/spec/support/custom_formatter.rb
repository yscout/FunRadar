# Custom RSpec formatter that shows percentage statistics
require 'rspec/core/formatters/documentation_formatter'

class CustomFormatter < RSpec::Core::Formatters::DocumentationFormatter
  RSpec::Core::Formatters.register self, :dump_summary

  def dump_summary(summary)
    super

    total = summary.example_count
    passed = total - summary.failure_count - summary.pending_count
    percentage = total > 0 ? (passed.to_f / total * 100).round(2) : 0

    output.puts "\n"
    output.puts "=" * 80
    output.puts "Test Results: #{passed}/#{total} passed (#{percentage}%)"
    output.puts "=" * 80
  end
end

