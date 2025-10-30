# Custom Test Formatters

This project includes custom formatters for both RSpec and Cucumber that display test results with pass percentages.

## Features

### RSpec Custom Formatter
- Located: `spec/support/custom_formatter.rb`
- Shows: `X/Total passed (X.XX%)`
- Automatically enabled in `.rspec` configuration

Example output:
```
================================================================================
Test Results: 141/141 passed (100.0%)
================================================================================
```

### Cucumber Custom Formatter
- Located: `features/support/custom_cucumber_formatter.rb`
- Shows: `X/Total passed (X.XX%)`
- Automatically enabled in `config/cucumber.yml`

Example output:
```
================================================================================
Scenario Results: 25/53 passed (47.17%)
================================================================================
```

## Usage

### Running Tests with Default Formatters

```bash
# RSpec with percentage output (default)
bundle exec rspec

# Cucumber with percentage output (default)
bundle exec cucumber
```

### Using Alternative Formatters

```bash
# RSpec with progress format (dots)
bundle exec rspec --format progress

# RSpec with documentation format
bundle exec rspec --format documentation

# Cucumber with pretty format
bundle exec cucumber --format pretty
```

## Implementation Details

### RSpec Formatter
- Extends `RSpec::Core::Formatters::DocumentationFormatter`
- Overrides `dump_summary` method to add percentage statistics
- Calculates: `passed = total - failures - pending`
- Percentage rounded to 2 decimal places

### Cucumber Formatter
- Extends `Cucumber::Formatter::Progress`
- Tracks test results via `on_test_case_finished` event
- Displays summary via `on_test_run_finished` event
- Handles passed, failed, pending, and skipped scenarios

## Configuration Files

### `.rspec`
```
--require spec_helper
--require ./spec/support/custom_formatter.rb
--format CustomFormatter
--color
```

### `config/cucumber.yml`
```
default: --publish-quiet --format Cucumber::Formatter::CustomProgress --require features
```

## Customization

To modify the output format, edit:
- RSpec: `spec/support/custom_formatter.rb` (line 9-15)
- Cucumber: `features/support/custom_cucumber_formatter.rb` (line 31-40)

To disable the custom formatters:
- RSpec: Remove the `--format CustomFormatter` line from `.rspec`
- Cucumber: Change format in `config/cucumber.yml` to `progress` or `pretty`

