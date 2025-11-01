## FunRadar

This is a code bundle for FunRadar App Design. Group members: Liang Song(ts3479), Mike Hu(yh3329), Wanting You(wy2470), Yutao Mao(ym3019). Heroku deployment: https://funradar-b8f29a7d90f1.herokuapp.com/

## What’s our first proposal?

FunRadar — Find fun, fast.

FunRadar instantly finds fun things to do near you — from food and drinks to activities and events — personalized to your vibe, preferences, and location. You just tell it what you feel like doing, and it returns a curated list that feels handpicked for you.

## What’s the additional problem we’re solving?

As we dig deeper about the scenario, we find out that people usual don’t hangout alone, but hangout with their friends. What’s the more painful pain point is that different people have different preferences, like different personal interests, budget, schedule, and location. Some people say they are ok with everything but denied it every time a proposal is raised. 

In our solution, we designed the coordination process to make everyone fill in their preferences before our system recommends the activities.

In this iteration, we designed and coded the collaboration process. In the next iteration, we will improve the recommendation system with real data using ai agents after collecting everyone’s preferences in this friend grouhp.

User stories are captured as Gherkin feature files under `backend/features/`, and RSpec specs all live in `backend/spec/`


## Run the Tests

### Run All RSpec Tests(141 examples)
```bash
cd backend
bundle install
bundle exec rspec
```

### Run a Specific Test File
```bash
bundle exec rspec spec/models/user_spec.rb
```

### Run RSpec with Detailed Output
```bash
bundle exec rspec --format documentation
```

### Run All Cucumber Tests(53 scenarios)
```bash
bundle exec cucumber
```

### Run a Specific Feature
```bash
bundle exec cucumber features/create_event.feature
```

### Run Cucumber with Detailed Output
```bash
bundle exec cucumber --format pretty
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

### Cucumber (53 scenarios, 100% core features passing)
- Create Event: 9 scenarios
- Submit Preferences: 13 scenarios
- AI Matching: 14 scenarios
- View Events: 8 scenarios
- User Management: 5 scenarios
- Event Collaboration: 4 scenarios

### How our project work
Our project is currently divided into three sections: onboarding/social matching/recommendations.

First, users can type their name and share the access of their location.

After they enter the main pages, they may see some upcoming events that have already matched with their friends(our engine will recommend these events first based on their availability/shared interests), or events that are pending(waiting invitee to accept).

They can also start a new event with their friends by clicking "start a new event". There they will input their availbility/things they are interested in/budgets, and we will base on their current preference and saved preference to recommend them with a list of events and friends that are possibly also interested in this events, and then they can send invitations to these friends.

After their friends log in and see the invitation, they can also input their preferences and rank these events. If 5 people agree with a certain event, the status will change from "pending" to "complete" and will be added to the schedule.

