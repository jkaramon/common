require 'rubygems'
require 'mongo_mapper'
$:.unshift( File.dirname(__FILE__) + '/../lib' )
require 'common'

RSpec.configure do |config|
  config.before(:all) { }
  config.after(:all) { }
end

