# -*- encoding: utf-8 -*-
require File.expand_path("../lib/common/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "common"
  s.version     = Common::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['VanillaDesk']
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/common"
  s.summary     = "A private gem to support vd and acm applications."
  s.description = "Common libraries supporting vd and acm apps."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "common"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec"
  
  s.add_dependency "airbrake"
  s.add_dependency "servolux"
  s.add_dependency "money", "3.1.5"




  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
