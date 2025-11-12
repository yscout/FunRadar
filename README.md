## FunRadar

This is a code bundle for FunRadar App Design. Group members: Liang Song (ts3479), Mike Hu (yh3329), Wanting You (wy2470), Yutao Mao (ym3019).
Heroku deployment: https://funradar-b8f29a7d90f1.herokuapp.com/

## What’s our first proposal?

FunRadar — Find fun, fast.

FunRadar instantly finds fun things to do near you — from food and drinks to activities and events — personalized to your vibe, preferences, and
location. You just tell it what you feel like doing, and it returns a curated list that feels handpicked for you.

## What’s the additional problem we’re solving?

As we dig deeper about the scenario, we find out that people usually don’t hang out alone, but hang out with their friends. What’s more painful
is that different people have different preferences, like interests, budget, schedule, and location. Some people say they are ok with everything
but reject every proposal.

In our solution, we designed the coordination process so everyone fills in their preferences before the system recommends activities. This
iteration focuses on the collaboration workflow; the next iteration will improve the recommendation system with real data via AI agents once
every friend shares preferences.

## What's our App

FunRadar has three major flows:

- __Onboarding__ – a lightweight sign-in where users share their name and optionally grant location permission so future matches can be localized.
- __Social planning__ – the home screen shows pending invites, ongoing events collecting preferences, and completed hangouts. Organizers can launch a new event by sharing availability, interests, budgets, and invitee names.
- __Preference collection + AI matching__ – each invitee fills in their availability/activities/budget before seeing AI-generated matches. Once all invitees submit, we run AI matching, surface recommended activities, and let everyone rate them until a final plan is chosen.

## How to Run It on Local Device

1. Install dependencies
```bash
cd backend
bundle install
npm install
```
2. Configure environment
- Copy `.env.example` to `.env` if present (or export manually).
- Set `OPENAI_KEY` to a valid API key so AI matchmaking works:
```bash
export OPENAI_KEY=sk-your-key-here
```
- Optionally set `PORT` (defaults to 3000).
3. Prepare the database
```bash
bin/rails db:setup
```
4. Run the app
```bash
bin/dev
```

This runs foreman with `Procfile.dev`, launching both ```bin/rails``` server and ```npm run build:watch``` so backend and React builds stay in sync.

5. Visit http://localhost:3000 to use the app.

## How to run RSpec

```bash
cd backend
bundle exec rspec              # run the full suite
bundle exec rspec spec/models/user_spec.rb          # single file
bundle exec rspec --format documentation             # verbose output
```

## How to run User Story

Cucumber features encode our user stories.
```bash
cd backend
bundle exec cucumber                               # all stories (features/)
bundle exec cucumber features/create_event.feature # specific feature
bundle exec cucumber --format pretty               # readable output

CUCUMBER_ENABLE_COVERAGE=false bundle exec cucumber # disable coverage if needed
```

Rerun ```bin/dev``` (or bin/rails server plus npm run build:watch) afterward if you need the server up while working through scenarios.

97 scenarios (97 passed)
611 steps (611 passed)
Line Coverage: 97.26% (390 / 401)
