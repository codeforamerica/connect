require 'spec_helper'

describe Connect do
  describe 'initial call' do
    let(:fake_calls_object) { double("Twilio Client Calls object", :create => 'call created!') }
    let(:fake_twilio_client) { double("Twilio::REST::Client", :calls => fake_calls_object) }
    let(:phone_number_to_connect) { '+14159998888' }
    let(:twilio_phone_number) { '+15101112222' }
    let(:button_sequence) { 'www1ww1ww2' }
    let(:twilio_sid) { 'faketwiliosid' }
    let(:twilio_auth) { 'faketwilioauth' }

    before do
      ENV['PHONE_NUMBER_TO_CONNECT'] = phone_number_to_connect
      ENV['TWILIO_PHONE_NUMBER'] = twilio_phone_number
      ENV['BUTTON_SEQUENCE_TO_REACH_HOLD'] = button_sequence
      ENV['TWILIO_SID'] = twilio_sid
      ENV['TWILIO_AUTH'] = twilio_auth
      allow(Twilio::REST::Client).to receive(:new).and_return(fake_twilio_client)
      post '/', { 'From' => '+12223334444' }
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
      expect(url).to eq('https://s3-us-west-1.amazonaws.com/cfa-health-connect/initial_call_response.wav')
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
        send_digits: button_sequence
      )
    end
  end
end
