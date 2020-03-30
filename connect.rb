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
      status_callback: "#{server_base_url}/connections/#{phone_number_digits_only}/hangup",
      status_callback_method: 'POST',
      url: "#{server_base_url}/hold?user_phone_number=#{params['From']}",
      method: 'GET'
    )
    response = Twilio::TwiML::VoiceResponse.new
    response.play(url: 'https://s3.amazonaws.com/connect-cfa/initial_call_voice_file_v2.mp3')
    response.hangup

    response.to_s
  end

  get '/hold' do
    # Twilio has called HSA and triggers this callback
    phone_number_without_spaces = params[:user_phone_number].gsub(" ","")
    response = Twilio::TwiML::VoiceResponse.new
    # Twilio plays Automated Phone Tree Sequence to get to Hold for next representative
    response.play(digits: ENV['BUTTON_SEQUENCE_TO_REACH_HOLD'])
    # Play message on loop until HSA Representative hears message and presses 1 to talk to client
    response.gather(numDigits: 1, action: "/connections/#{phone_number_without_spaces}/connect", method: 'POST') do |g|
      g.pause(length: 3)
      g.play(url: "https://s3-us-west-1.amazonaws.com/cfa-health-connect/leo.wav", loop: '0')
    end
    response.to_s
  end

  post '/connections/:phone_number/connect' do
    phone_number_with_plus_sign = '+' + params[:phone_number]
    response = Twilio::TwiML::VoiceResponse.new
    response.dial(number: phone_number_with_plus_sign)

    response.to_s
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

    response = Twilio::TwiML::VoiceResponse.new
    response.to_s
  end

  get '/end' do
    response = Twilio::TwiML::VoiceResponse.new
    response.gather(numDigits: 1, action: "/hangup-report/#{params['caller_number']}", method: 'POST') do |g|
      g.play(url: "https://s3.amazonaws.com/connect-cfa/did_they_hang_up.mp3")
    end
    response.to_s
  end

  post '/hangup-report/:phone_number' do
    response = Twilio::TwiML::VoiceResponse.new
    response.hangup

    response.to_s
  end
end
