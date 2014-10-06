require 'sinatra'
require 'twilio-ruby'

class Connect < Sinatra::Base
  post '/' do
    response = Twilio::TwiML::Response.new do |r|
      r.Play 'https://s3-us-west-1.amazonaws.com/cfa-health-connect/initial_call_response.wav'
    end
    response.text
  end
end
