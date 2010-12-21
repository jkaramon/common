require 'simplecov'
SimpleCov.adapters.define 'default' do
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/config/'
  add_filter "/vendor/"
  
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Libraries', 'lib'
end

SimpleCov.adapters.define 'gem' do
  add_filter '/spec/'
  add_filter "/vendor/"
end


