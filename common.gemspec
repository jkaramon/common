# -*- encoding: utf-8 -*-
require File.expand_path("../lib/common/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "common"
  s.version     = Common::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/common"
  s.summary     = "TODO: Write a gem summary"
  s.description = "TODO: Write a gem description"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "common"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "2.0.1"
  s.add_development_dependency "ruby-debug19"
  s.add_development_dependency "watchr"


  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
