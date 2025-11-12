# Test Coverage Guide

## Understanding the Coverage Report

### Overall Metrics
- **Line Coverage: 83.08%** (334/402 lines) - Percentage of code lines executed during tests
- **Branch Coverage: 77.78%** (84/108 branches) - Percentage of conditional branches (if/else) tested
- **Test Results: 148/151 passed (98.01%)** - Most tests pass, but coverage can improve

### What Coverage Means

1. **Line Coverage**: Measures if a line of code was executed at least once during tests
   - 100% = Every line was run
   - 0% = No lines were run (untested code)

2. **Branch Coverage**: Measures if all paths through conditionals were tested
   - Example: `if x > 0` needs tests for both `x > 0` (true) and `x <= 0` (false)

### Files Needing Attention

#### 🔴 Critical (0% Coverage)
1. **`pages_controller.rb`** (0% - 4 lines)
   - Simple controller, test is currently skipped
   - Easy win: Unskip and test the home action

2. **`event_votes_controller.rb`** (0% - 42 lines)
   - Entire voting controller is untested
   - Critical functionality for the app
   - Needs comprehensive test suite

#### 🟡 Medium Priority (Low Coverage)
3. **`invitations_controller.rb`** (79.17% - 5 lines missing)
   - Missing: `index` action test (lines 8-11)
   - Missing: Error handling in `update` (line 29)

4. **`event.rb`** (80.95% - 12 lines missing)
   - Missing: Several edge cases in methods
   - Missing: `finalize_if_ready!` method (lines 67-87)
   - Missing: Some branches in `to_api` method

#### 🟢 Low Priority (High Coverage)
5. **`activity_suggestion.rb`** (87.50% - 1 line)
6. **`match_vote.rb`** (90.00% - 1 line)
7. **`group_match_service.rb`** (93.62% - 3 lines)

## How to Increase Coverage

### Step 1: Identify Missing Code
Look at the coverage report's "missing" column to see exact line numbers:
```
|   0.00%  | app/controllers/api/event_votes_controller.rb | 42    | 42     | 1-5, 7-10, 12-17, 19-24, 26-32, 34, 36-38, 40-44, 46-50 |
```
This tells you lines 1-5, 7-10, etc. are not covered.

### Step 2: Write Tests for Missing Code

#### For Controllers (Request Specs)
```ruby
# spec/requests/api/event_votes_spec.rb
RSpec.describe "Api::EventVotes", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:event) { create(:event, organizer: user) }
  
  describe "POST /api/events/:event_id/votes" do
    it "creates votes successfully" do
      # Test the happy path
    end
    
    it "handles errors" do
      # Test error cases
    end
  end
end
```

#### For Models (Model Specs)
```ruby
# spec/models/event_spec.rb
RSpec.describe Event, type: :model do
  describe '#finalize_if_ready!' do
    it "finalizes when all votes are in" do
      # Test the method
    end
  end
end
```

### Step 3: Run Tests and Check Coverage

```bash
# Run tests with coverage
cd backend
bundle exec rspec --format documentation

# Coverage report is generated automatically
# Check backend/coverage/index.html for detailed view
```

### Step 4: Focus on High-Impact Areas

1. **Start with 0% coverage files** - Biggest impact
2. **Test critical paths** - User-facing features
3. **Test error cases** - Edge cases and error handling
4. **Test branches** - All if/else paths

## Best Practices

1. **Test Behavior, Not Implementation**
   - Focus on what the code does, not how
   - Tests should still pass if you refactor

2. **Use Descriptive Test Names**
   ```ruby
   it "returns error when invitation not found" # Good
   it "test 1" # Bad
   ```

3. **Test Edge Cases**
   - Empty inputs
   - Invalid inputs
   - Boundary conditions
   - Error scenarios

4. **Use Factories**
   ```ruby
   let(:user) { create(:user) }  # Good
   User.create!(name: "Test")     # Less maintainable
   ```

5. **Keep Tests Independent**
   - Each test should work in isolation
   - Use `before` blocks for setup, not dependencies between tests

## Running Coverage Locally

```bash
cd backend
bundle exec rspec
# Coverage report: backend/coverage/index.html
```

## Target Coverage Goals

- **Minimum**: 80% line coverage (you're at 83.08% ✅)
- **Good**: 90% line coverage
- **Excellent**: 95%+ line coverage
- **Branch Coverage**: Aim for 85%+ (you're at 77.78%)

## Next Steps

1. ✅ Write tests for `event_votes_controller.rb` (0% → 100%)
2. ✅ Unskip and test `pages_controller.rb` (0% → 100%)
3. ✅ Complete `invitations_controller.rb` tests (79% → 100%)
4. ✅ Add missing `event.rb` tests (81% → 95%+)
5. ✅ Fill in remaining edge cases

