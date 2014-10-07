Connect
=======

A digital service for calling social service offices — call a number to have your place held instead of waiting on hold; when a human representative is availalble, you get a call connecting directly with them!

### What it is

This is an early-stage Python app (currently being rewritten in Ruby) built on Twilio meant to serve as a proof of concept. Currently, using this app you can:

- Initiate a call to a specified number
- Have Twiilio wait while you are on hold waiting for service
- Prompt the service provider to connect with the user when they answer.
- Merge the callers when the prompt is accepted.

The origina idea was from a conversation between @alanjosephwilliams and @lippytak, when discussing their ongoing research. The ideas of @daguar greatly influence how we percieve the potential value of the service. Further discussion of the idea can be found in the [ideas repo](https://github.com/codeforamerica/health-project-ideas/issues/38).

This is a project of CFA's Health SpecOps Team.

### Benefits
1. Stop wasting your time
2. Stop wasting your minutes

### Deployment

In the Ruby version (v2) of the app, deploy to Heroku and set the following environment variables:

- `PHONE_NUMBER_TO_CONNECT`: the phone number of the office to call, for example '+14151112222'
- `BUTTON_SEQUENCE_TO_REACH_HOLD`: a button sequence that gets you to the "holding" part of the phone system, for example "www1ww1ww2" for "wait 1.5 seconds, press 1, wait 1 second, press 1, wait 1 second, press 2"
- `TWILIO_SID`: your Twilio SID
- `TWILIO_AUTH`: your Twilio auth token
- `TWILIO_PHONE_NUMBER`: your Twilio-purchased phone number

Then, in the Twilio dashboard, configure the "voice URL" for your phone number to "https://my-app-name.herokuapp.com/call/initiate"

### Local Development

For the Ruby version of the app, to get started, clone the repo and cd into the directory.

You will need to use Ruby 2.1.1 for this app. To install, we recommend using RVM (`rvm install 2.1.1`).

Then, install dependencies:

`bundle install`

And run tests simply with:

`rspec`

