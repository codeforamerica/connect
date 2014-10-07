require 'sinatra'
require 'twilio-ruby'
require 'rack/ssl'

class Connect < Sinatra::Base
  use Rack::SSL unless settings.environment == :development or settings.environment == :test

  if settings.environment == :production
    set :url_scheme, 'https'
  else
    set :url_scheme, 'http'
  end

  post '/call/initiate' do
    client = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH'])
    server_base_url = settings.url_scheme + '://' + request.env['HTTP_HOST']
    client.calls.create(
      to: ENV['PHONE_NUMBER_TO_CONNECT'],
      from: ENV['TWILIO_PHONE_NUMBER'],
      send_digits: ENV['BUTTON_SEQUENCE_TO_REACH_HOLD'],
      url: "#{server_base_url}/hold"
    )
    response = Twilio::TwiML::Response.new do |r|
      r.Play 'https://s3-us-west-1.amazonaws.com/cfa-health-connect/initial_call_response.wav'
      r.Hangup
    end
    response.text
  end

  get '/hold' do
  end
end
