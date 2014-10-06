require 'spec_helper'

describe Connect do
  describe 'initial call' do
    before do
      post '/'
    end

    it 'responds' do
      expect(last_response.status).to eq(200)
    end

    it 'plays a voice file to the user' do
      parsed_response = Nokogiri.parse(last_response.body)
      url = parsed_response.xpath('//Response//Play').children[0].text
      expect(url).to eq('https://s3-us-west-1.amazonaws.com/cfa-health-connect/initial_call_response.wav')
    end
  end
end
