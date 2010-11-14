require 'rubygems'
require 'mongo_mapper'
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

