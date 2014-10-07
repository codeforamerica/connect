require 'sinatra'
require 'twilio-ruby'

class Connect < Sinatra::Base
  post '/' do
    client = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH'])
    client.calls.create(
      to: ENV['PHONE_NUMBER_TO_CONNECT'],
      from: ENV['TWILIO_PHONE_NUMBER'],
      send_digits: ENV['BUTTON_SEQUENCE_TO_REACH_HOLD']
    )
    response = Twilio::TwiML::Response.new do |r|
      r.Play 'https://s3-us-west-1.amazonaws.com/cfa-health-connect/initial_call_response.wav'
      r.Hangup
    end
    response.text
  end
end
