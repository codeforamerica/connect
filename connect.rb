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
    phone_number_digits_only = params['From'].gsub("+","")
    client.calls.create(
      to: ENV['PHONE_NUMBER_TO_CONNECT'],
      from: ENV['TWILIO_PHONE_NUMBER'],
      send_digits: ENV['BUTTON_SEQUENCE_TO_REACH_HOLD'],
      status_callback: "#{server_base_url}/connections/#{phone_number_digits_only}/hangup",
      status_callback_method: 'POST',
      url: "#{server_base_url}/hold?user_phone_number=#{params['From']}",
      method: 'GET'
    )
    response = Twilio::TwiML::Response.new do |r|
      r.Play 'https://s3.amazonaws.com/connect-cfa/initial_call_voice_file_v1.mp3'
      r.Hangup
    end
    response.text
  end

  get '/hold' do
    phone_number_without_spaces = params[:user_phone_number].gsub(" ","")
    response = Twilio::TwiML::Response.new do |r|
      r.Gather(numDigits: 1, action: "/connections/#{phone_number_without_spaces}/connect", method: 'POST') do |g|
        g.Pause(length: 3)
        g.Play("https://s3-us-west-1.amazonaws.com/cfa-health-connect/leo.wav", loop: '0')
      end
    end
    response.text
  end

  post '/connections/:phone_number/connect' do
    phone_number_with_plus_sign = '+' + params[:phone_number]
    response = Twilio::TwiML::Response.new do |r|
      r.Dial phone_number_with_plus_sign
    end
    response.text
  end

  post '/connections/:phone_number/hangup' do
    phone_number_with_plus_sign = '+' + params[:phone_number]
    client = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH'])
    server_base_url = settings.url_scheme + '://' + request.env['HTTP_HOST']
    client.calls.create(
      to: phone_number_with_plus_sign,
      from: ENV['TWILIO_PHONE_NUMBER'],
      url: "#{server_base_url}/end?caller_number=#{params[:phone_number]}",
      method: 'GET'
    )
    response = Twilio::TwiML::Response.new do |r|
    end
    response.text
  end

  get '/end' do
    response = Twilio::TwiML::Response.new do |r|
      r.Gather(numDigits: 1, action: "/hangup-report/#{params['caller_number']}", method: 'POST') do |g|
        g.Play("https://s3-us-west-1.amazonaws.com/cfa-health-connect/did_they_hang_up.mp3")
      end
    end
    response.text
  end

  post '/hangup-report/:phone_number' do
    response = Twilio::TwiML::Response.new do |r|
      r.Hangup
    end
    response.text
  end
end
