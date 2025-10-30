# Testing Guide for FunRadar Backend

## Quick Start

### Run All Tests
```bash
# Run all RSpec tests (141 examples)
bundle exec rspec

# Run all Cucumber scenarios (53 scenarios)
bundle exec cucumber

# Run everything
bundle exec rspec && bundle exec cucumber
```

## RSpec Testing

### Run Specific Tests
```bash
# Run all model tests
bundle exec rspec spec/models

# Run specific model test
bundle exec rspec spec/models/user_spec.rb

# Run specific test by line number
bundle exec rspec spec/models/user_spec.rb:15
```

### Output Formats
```bash
# Custom format with percentage stats (default)
bundle exec rspec

# Progress format (dots)
bundle exec rspec --format progress

# Documentation format (detailed, readable)
bundle exec rspec --format documentation

# With failure details
bundle exec rspec --format documentation --fail-fast
```

**Note:** The default RSpec configuration now includes a custom formatter that displays test results with percentages at the end:
```
================================================================================
Test Results: 141/141 passed (100.0%)
================================================================================
```

### Run Tests by Tag
```bash
# Run only model tests
bundle exec rspec --tag type:model

# Run only request tests
bundle exec rspec --tag type:request
```

## Cucumber Testing

### Run Specific Features
```bash
# Run all features
bundle exec cucumber

# Run specific feature file
bundle exec cucumber features/create_event.feature

# Run specific scenario by line number
bundle exec cucumber features/create_event.feature:9
```

### Output Formats
```bash
# Custom progress format with percentage stats (default)
bundle exec cucumber

# Pretty format (detailed)
bundle exec cucumber --format pretty

# Show only failures
bundle exec cucumber --format pretty --strict
```

**Note:** The default Cucumber configuration now includes a custom formatter that displays scenario results with percentages at the end:
```
================================================================================
Scenario Results: 25/53 passed (47.17%)
================================================================================
```

## Test Coverage

### RSpec (148 examples, 100% passing)
- **Model Tests**: 90 examples
  - User: 16 tests
  - Event: 30 tests
  - Invitation: 24 tests
  - Preference: 20 tests
  
- **Service Tests**: 15 examples
  - AI::GroupMatchService: 15 tests
  
- **Request Tests**: 43 examples
  - Events API: 19 tests
  - Invitations API: 6 tests
  - Preferences API: 11 tests
  - User API: 4 tests
  - Session API: 3 tests

### Cucumber (53 scenarios, 47% core features passing)
- Create Event: 9 scenarios
- Submit Preferences: 13 scenarios
- AI Matching: 14 scenarios
- View Events: 8 scenarios
- User Management: 5 scenarios
- Event Collaboration: 4 scenarios

## Common Test Commands

### Development Workflow
```bash
# Run tests on file save (install guard first)
bundle exec guard

# Run only failed tests from last run
bundle exec rspec --only-failures

# Run tests in random order
bundle exec rspec --order random
```

### Debugging Tests
```bash
# Run with detailed failure information
bundle exec rspec --format documentation --backtrace

# Focus on specific test (add 'focus: true' to test)
bundle exec rspec --tag focus

# Run tests without capturing output
bundle exec rspec --format documentation --no-color
```

## Writing New Tests

### RSpec Example
```ruby
require 'rails_helper'

RSpec.describe MyModel, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
  
  describe '#my_method' do
    it 'does something' do
      model = create(:my_model)
      expect(model.my_method).to eq('expected')
    end
  end
end
```

### Cucumber Example
```gherkin
Feature: My Feature
  As a user
  I want to do something
  So that I can achieve a goal
  
  Scenario: Successful action
    Given I am logged in as "John"
    When I click "Create Event"
    Then I should see "Event created"
```

## Tips

1. **Use Factories**: Prefer `create(:model)` over direct instantiation
2. **Keep Tests Fast**: Use `build` instead of `create` when database persistence isn't needed
3. **Test One Thing**: Each test should verify one behavior
4. **Use Descriptive Names**: Test names should explain what's being tested
5. **Mock External Services**: Always mock API calls to keep tests fast and reliable

## Troubleshooting

### Tests Failing After Gem Update
```bash
bundle exec rails db:test:prepare
```

### Factory Errors
```bash
# Check factory definitions
bundle exec rspec spec/factories
```

### Database Issues
```bash
# Reset test database
RAILS_ENV=test bundle exec rails db:drop db:create db:migrate
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run RSpec
  run: bundle exec rspec
  
- name: Run Cucumber
  run: bundle exec cucumber
```

## Resources

- [RSpec Documentation](https://rspec.info/)
- [Cucumber Documentation](https://cucumber.io/docs/)
- [FactoryBot Guide](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)

