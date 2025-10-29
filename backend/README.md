# FunRadar Backend

Rails API backend for FunRadar - An intelligent event planning and group activity matching application.

## Testing

This project includes comprehensive test coverage with custom formatters that display pass percentages.

### Quick Start

```bash
# Run all RSpec tests (141 examples)
bundle exec rspec

# Run all Cucumber scenarios (53 scenarios)
bundle exec cucumber

# Run everything
bundle exec rspec && bundle exec cucumber
```

### Test Output with Percentages

Both RSpec and Cucumber tests now display results with percentages:

**RSpec Output:**
```
================================================================================
Test Results: 141/141 passed (100.0%)
================================================================================
```

**Cucumber Output:**
```
================================================================================
Scenario Results: 25/53 passed (47.17%)
================================================================================
```

For detailed testing documentation, see [TESTING.md](TESTING.md)

For formatter implementation details, see [TEST_FORMATTER_README.md](TEST_FORMATTER_README.md)
