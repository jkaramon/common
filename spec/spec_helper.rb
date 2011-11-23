require 'rubygems'
require 'common/simplecov_adapter'
SimpleCov.start 'gem'

$:.unshift( File.dirname(__FILE__) + '/../lib' )

require 'mongo_mapper'
require "action_view/railtie"
require "action_controller/railtie"
require 'common'
require 'money'

module Airbrake
  def self.notify(*args)
    # do nothing.
  end
end

RSpec.configure do |config|
  config.before(:all) { }
  config.after(:all) { }
end

