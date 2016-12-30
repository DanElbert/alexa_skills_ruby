require 'rubygems'
require 'bundler/setup'
require 'oj'
require 'rspec'
require 'time'
require 'webmock/rspec'
require File.expand_path('../../lib/alexa_skills_ruby', __FILE__)

MultiJson.use :oj

Dir[File.expand_path('../support/**/*', __FILE__)].each { |f| require f }

RSpec.configure do |config|

  config.include FixtureSupport
  config.include X509Support

end