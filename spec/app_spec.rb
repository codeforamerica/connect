require 'spec_helper'

describe Connect do
  describe 'initial call' do
    let(:fake_calls_object) { double("Twilio Client Calls object", :create => 'call created!') }
    let(:fake_twilio_client) { double("Twilio::REST::Client", :calls => fake_calls_object) }
    let(:phone_number_to_connect) { '+14159998888' }
    let(:caller_phone_number) { '+12223334444'}
    let(:twilio_phone_number) { '+15101112222' }
    let(:button_sequence) { 'www1ww1ww2' }
    let(:twilio_sid) { 'faketwiliosid' }
    let(:twilio_auth) { 'faketwilioauth' }
    let(:loop_audio_url) { 'https://www.example.com/fake-loop-audio-url.mp3' }

    before do
      ENV['PHONE_NUMBER_TO_CONNECT'] = phone_number_to_connect
      ENV['TWILIO_PHONE_NUMBER'] = twilio_phone_number
      ENV['BUTTON_SEQUENCE_TO_REACH_HOLD'] = button_sequence
      ENV['TWILIO_SID'] = twilio_sid
      ENV['TWILIO_AUTH'] = twilio_auth
      ENV['LOOP_AUDIO_URL'] = loop_audio_url
      allow(Twilio::REST::Client).to receive(:new).and_return(fake_twilio_client)
      post '/call/initiate', { 'From' => caller_phone_number }
    end

    it 'responds' do
      expect(last_response.status).to eq(200)
    end

    it 'instantiates a Twilio client with the correct credentials' do
      expect(Twilio::REST::Client).to have_received(:new).with(twilio_sid, twilio_auth)
    end

    it 'plays a voice file to the user' do
      parsed_response = Nokogiri.parse(last_response.body)
      url = parsed_response.xpath('//Response//Play').children[0].text
      expect(url).to eq('https://s3.amazonaws.com/connect-cfa/initial_call_voice_file_v3_100715.mp3')
    end

    it 'then hangs up' do
      parsed_response = Nokogiri.parse(last_response.body)
      last_xml_element = parsed_response.xpath('//Response').children.last.name
      expect(last_xml_element).to eq('Hangup')
    end

    it 'initiates a call with proper arguments' do
      expect(fake_calls_object).to have_received(:create).with(
        to: phone_number_to_connect,
        from: twilio_phone_number,
        send_digits: button_sequence,
        status_callback: 'http://example.org/connections/12223334444/hangup',
        status_callback_method: 'POST',
        url: "http://example.org/hold?user_phone_number=#{caller_phone_number}",
        method: 'GET'
      )
    end
  end

  describe 'GET /hold' do
    let(:caller_phone_number) { '+12223334444'}

    it 'returns TwiML to play voice on loop and call user when representative presses a number' do
      get "/hold?user_phone_number=#{caller_phone_number}"
      clean_phone_number = caller_phone_number.gsub("+","")
      expected_twiml = Twilio::TwiML::Response.new do |r|
        r.Gather(numDigits: 1, action: "/connections/#{clean_phone_number}/connect", method: 'POST') do |g|
          g.Pause(length: 3)
          g.Play('https://www.example.com/fake-loop-audio-url.mp3', loop: 0)
        end
      end.text
      expect(last_response.body).to eq(expected_twiml)
    end
  end

  describe 'connecting rep with user (POST /connections/:phone_number/connect)' do
    context 'if the representative presses a button' do
      let(:caller_phone_number_digits_only) { '12223334444'}

      before do
        post "/connections/#{caller_phone_number_digits_only}/connect", { 'Digits' => '1' }
      end

      it 'dials the user' do
        expected_twiml = Twilio::TwiML::Response.new do |r|
          r.Dial("+#{caller_phone_number_digits_only}")
        end.text
        expect(last_response.body).to eq(expected_twiml)
      end
    end
  end

  describe 'completion of call' do
    let(:fake_calls_object) { double("Twilio Client Calls object", :create => 'call created!') }
    let(:fake_twilio_client) { double("Twilio::REST::Client", :calls => fake_calls_object) }
    let(:twilio_phone_number) { '+15101112222' }
    let(:twilio_sid) { 'faketwiliosid' }
    let(:twilio_auth) { 'faketwilioauth' }
    let(:caller_phone_number_digits_only) { '12223334444'}

    before do
      ENV['TWILIO_PHONE_NUMBER'] = twilio_phone_number
      ENV['TWILIO_SID'] = twilio_sid
      ENV['TWILIO_AUTH'] = twilio_auth
      allow(Twilio::REST::Client).to receive(:new).and_return(fake_twilio_client)
      post "/connections/#{caller_phone_number_digits_only}/hangup"
    end

    it 'instantiates a Twilio client with the correct credentials' do
      expect(Twilio::REST::Client).to have_received(:new).with(twilio_sid, twilio_auth)
    end

    it 'calls the user' do
      number_with_plus_sign = "+" + caller_phone_number_digits_only
      expect(fake_calls_object).to have_received(:create).with(
        to: number_with_plus_sign,
        from: twilio_phone_number,
        url: "http://example.org/end?caller_number=#{caller_phone_number_digits_only}",
        method: 'GET'
      )
    end
  end

  describe '/end' do
    it 'provides twiml' do
      caller_number_value = '12223334444'
      get "/end?caller_number=#{caller_number_value}"
      expected_twiml = Twilio::TwiML::Response.new do |r|
        r.Gather(numDigits: 1, action: "/hangup-report/#{caller_number_value}", method: 'POST') do |g|
          g.Play("https://s3.amazonaws.com/connect-cfa/did_they_hang_up.mp3")
        end
      end.text
      expect(last_response.body).to eq(expected_twiml)
    end
  end

  describe 'hangup report' do
    it 'hangs up' do
      post '/hangup-report/12223334444', { 'Digits' => 1 }
      expected_twiml = Twilio::TwiML::Response.new do |r|
        r.Hangup
      end.text
      expect(last_response.body).to eq(expected_twiml)
    end
  end
end
