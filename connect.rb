require 'sinatra'
require 'twilio-ruby'

class Connect < Sinatra::Base
  post '/' do
    client = Twilio::REST::Client.new('1','2')
    client.calls.create(to: ENV['CONNECT_PHONE_NUMBER'])
    response = Twilio::TwiML::Response.new do |r|
      r.Play 'https://s3-us-west-1.amazonaws.com/cfa-health-connect/initial_call_response.wav'
      r.Hangup
    end
    response.text
  end
end
