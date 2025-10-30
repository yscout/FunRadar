# Testing Results for FunRadar Backend

This is a brief illustration of running RSpec/Cucumber testings and respective results.

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
```

## Cucumber Testing

### Run Specific Features
```bash
# Run all features
bundle exec cucumber

# Run specific feature file
bundle exec cucumber features/create_event.feature
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

