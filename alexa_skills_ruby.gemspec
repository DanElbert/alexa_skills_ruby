# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alexa_skills_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "alexa_skills_ruby"
  spec.version       = AlexaSkillsRuby::VERSION
  spec.authors       = ["Dan Elbert"]
  spec.email         = ["dan.elbert@gmail.com"]
  spec.homepage      = 'https://github.com/DanElbert/alexa_skills_ruby'
  spec.summary       = %q{Simple library to interface with the Alexa Skills Kit}

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '>= 4.2'
  spec.add_runtime_dependency "multi_json", "~> 1.0"
  spec.add_runtime_dependency 'addressable', '~> 2.5'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "oj", "~> 2.10"
  spec.add_development_dependency "webmock", "~> 2.3"
end