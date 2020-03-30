source 'https://rubygems.org'
ruby_version = File.read(File.join(File.dirname(__FILE__), '.ruby-version')).strip
ruby ruby_version

gem 'sinatra'
gem 'twilio-ruby'
gem 'rack-ssl'

group :test, :development do
  gem 'rspec'
  gem 'rack-test'
  gem 'pry'
  gem 'nokogiri'
  gem 'foreman'
end
