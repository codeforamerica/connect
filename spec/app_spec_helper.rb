require 'spec_helper'
require 'rack/test'
require 'nokogiri'
require 'sinatra'
require File.expand_path('../rack_spec_helpers', __FILE__)

RSpec.configure do |config|
  config.include RackSpecHelpers
  config.before(:example, :type => :feature) do
    require File.expand_path('../connect', __FILE__)
    self.app = Connect
  end
end
