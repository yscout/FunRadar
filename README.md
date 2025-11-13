## FunRadar

This is a code bundle for FunRadar App Design. Group members: Liang Song (ts3479), Mike Hu (yh3329), Wanting You (wy2470), Yutao Mao (ym3019).
Heroku deployment: https://funradar-b8f29a7d90f1.herokuapp.com/

## What’s our first proposal?

FunRadar — Find fun, fast. It will instantly finds fun things to do near you. From food and drinks to activities and events, it will recommend events that are personalized to your vibe, preferences, and location. You just tell it what you feel like doing at that time, and it returns a curated list that feels handpicked for you.

## What’s the additional problem we’re solving?

As we dig deeper about the scenario, we find out that people usually don’t hang out alone, but hang out with their friends. What’s more painful is that different people have different preferences, like interests, budget, schedule, and location. Some people say they are ok with everything but reject every proposal.

In our solution, we designed the coordination process so everyone fills in their preferences before the system recommends activities. This iteration focuses on the collaboration workflow; the next iteration will improve the recommendation system with real data via AI agents once every friend shares preferences.

## What's our App

FunRadar has three major flows:

- __Onboarding__ – a lightweight sign-in where users share their name and optionally grant location permission so future matches can be localized.
- __Social planning__ – the home screen shows pending invites, ongoing events collecting preferences, and completed hangouts. Organizers can launch a new event by sharing availability, interests, budgets, and invitee names.
- __Preference collection + AI matching__ – each invitee fills in their availability/activities/budget before seeing AI-generated matches. Once all invitees submit, we run AI matching, surface recommended activities, and let everyone rate them until a final plan is chosen.

## Workflow of our APP:

1. Set up and log in: click "Get Started" and enter your username(userid); choose to enable location(it is also ok to close it) and then you can see your dashboard!

2. Normally, you won't see any upcoming events since you are a new user. You can start create your first own event by clicking the button, and choose your availability/preference/budgets/specific ideas. Then you can send this event to your friend by entering their username(e.g. "Ben", "Sarah")

3. After you send this request, you will see a pending event that is waiting for the response from the people you invite. To respond, you can click the log out button on top right, and enter the name you just invite your event to(e.g. "Ben", "Sarah").

4. After log in their account, you will see a notice of invitation. Click "respond", and you can see the details of event you just made. It is your time to share your preference as well! You can also type in and choose your availability/preference/budgets/specific ideas and click submit.

5. After your response, you will see an event detail page which lists activities all people who have be invited(e.g pending/responded). WAIT FOR SOME SECONDS, our AI recommendation system is working and calculating events that you guys all may like based on all information provided! Please wait for some time (like 10-20s, depending the amount of info you provided), and then you will see ths status of event changed from "AI matching" to "matched", and you will see the recommendation accordingly.

6. Now, every participant of the same event will see the SAME page of AI recommendations. It is a list of recommended events from AI. Everyone(you and other invitees) can rate each event from 1 star to 5 stars! After all participants rated the events, you can select the one with the highest score from all raters, and can accordingly add this event to everyone's calendars on home page

WARNING: If you test locally, the AI recommendation system is not working as we haven't export OPENAI KEY for your local environment. However, if tested through the link of heroku website, the AI recommendation system is working! We have exported OPENAI KEY on heroku!

<img width="490" height="390" alt="3201762995066_ pic" src="https://github.com/user-attachments/assets/07041ed0-5bfd-4be6-abdb-5d4058aba7f7" />
<img width="490" height="390" alt="3211762995066_ pic" src="https://github.com/user-attachments/assets/755b7cc9-0218-485c-a5b6-a618ee88876e" />
<img width="720" height="430" alt="3231762995642_ pic_hd" src="https://github.com/user-attachments/assets/82752f24-ec34-45f6-82a6-32b627a75347" />

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
export OPENAI_KEY=sk-your-key-here #we may not provide the OPENAI KEY in this public repo, but OPENAI KEY is exported on heroku!
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
bundle exec rspec  # run the full suite
bundle exec rspec spec/models/user_spec.rb  # single file
bundle exec rspec --format documentation  # verbose output
```

## How to run User Story

Cucumber features encode our user stories.
```bash
cd backend
bundle exec cucumber   # all stories (features/)
bundle exec cucumber features/create_event.feature # specific feature
bundle exec cucumber --format pretty # readable output

CUCUMBER_ENABLE_COVERAGE=false bundle exec cucumber # disable coverage if needed
```

Rerun ```bin/dev``` (or bin/rails server plus npm run build:watch) afterward if you need the server up while working through scenarios.

## Test Coverage Summary

``` bash
RSpec Tests (Unit & Integration): we have 187 examples and 0 failures

Cucumber Tests (User Stories/BDD): we have 97 scenarios (97 passed) and 611 steps (611 passed)

Coverage Metrics:
1. Line Coverage: 98.71% (382 / 387 lines)
2. Branch Coverage: 88.79% (103 / 116 branches)

```
