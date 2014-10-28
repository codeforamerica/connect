Connect
=======

[![Build Status](https://travis-ci.org/codeforamerica/connect.svg)](https://travis-ci.org/codeforamerica/connect)

A digital service to improve the experience of calling social service offices — call a number to have your place held, instead of waiting on hold. When a human is on the other line, you get a call back!

### What it is

This is a [beta-stage digital service](https://www.gov.uk/service-manual/phases) built using Twilio.

The current flow works like this:

- You call in and hear a pleasant message that we'll call you back someone's ready
- The service calls the agency, and enters digits to get to the "holding" screen
- When an agency rep picks up, they hear a message from their boss telling them to press 1 to connect with a client
- You get a call connecting you with the rep!

AFTER the call, you will get _another_ call asking you if you were connected with a rep or not (by pressing 1 or 2). This way we gather data on how frequently agency reps are hanging up.

The original idea was from a conversation between @alanjosephwilliams and @lippytak, when discussing their ongoing research. The ideas of @daguar greatly influence how we perceive the potential value of the service. Further discussion of the idea can be found in the [ideas repo](https://github.com/codeforamerica/health-project-ideas/issues/38).

This is a project of CFA's Health SpecOps Team.

### Benefits
1. Stop wasting your time
2. Stop wasting your minutes

### Deployment

To deploy, push to Heroku and then set the following environment variables:

- `PHONE_NUMBER_TO_CONNECT`: the phone number of the office to call, for example '+14151112222'
- `BUTTON_SEQUENCE_TO_REACH_HOLD`: a button sequence that gets you to the "holding" part of the phone system, for example "www1ww1ww2" for "wait 1.5 seconds, press 1, wait 1 second, press 1, wait 1 second, press 2"
- `TWILIO_SID`: your Twilio SID
- `TWILIO_AUTH`: your Twilio auth token
- `TWILIO_PHONE_NUMBER`: your Twilio-purchased phone number

Then, in the Twilio dashboard, configure the "voice URL" for your phone number to be a POST to "https://my-app-name.herokuapp.com/call/initiate"

### Local Development

To get started, clone the repo and cd into the directory.

You will need to use Ruby 2.1.1 for this app. To install, we recommend using RVM (`rvm install 2.1.1`).

Then, install dependencies:

`bundle install`

And run tests simply with:

`rspec`

### License & Copyright

Copyright Code for America Labs, 2014; MIT License
