require 'spec_helper'

describe Connect do
  describe 'initial call' do
    it 'responds' do
      post '/'
      expect(last_response.status). to eq(200)
    end
  end
end
