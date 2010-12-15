require 'rubygems'
require 'mongo_mapper'
require "action_view/railtie"
require "action_controller/railtie"

$:.unshift( File.dirname(__FILE__) + '/../lib' )
require 'common'

# Disable Hoptoad
module HoptoadNotifier
  def self.notify(thing)
    # do nothing.
  end
end

RSpec.configure do |config|
  config.before(:all) { }
  config.after(:all) { }
end

