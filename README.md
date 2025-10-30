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


## Running the Tests

### Run All RSpec Tests
```bash
cd backend
bundle install
bundle exec rspec
```

### Run Specific Test File
```bash
bundle exec rspec spec/models/user_spec.rb
```

### Run RSpec with Detailed Output
```bash
bundle exec rspec --format documentation
```

### Run All Cucumber Tests
```bash
bundle exec cucumber
```

### Run Specific Feature
```bash
bundle exec cucumber features/create_event.feature
```

### Run Cucumber with Detailed Output
```bash
bundle exec cucumber --format pretty
```


