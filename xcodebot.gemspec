# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcodebot/version'

Gem::Specification.new do |spec|
  spec.name          = Xcodebot::NAME
  spec.version       = Xcodebot::VERSION
  spec.authors       = ["j2shnz"]
  spec.email         = ["jessy.hanzo@gmail.com"]

  spec.summary       = Xcodebot::SUMMARY
  spec.description   = Xcodebot::DESCRIPTION
  spec.homepage      = Xcodebot::GITHUB
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "commander", "~> 4.4"
  spec.add_development_dependency "colorize", "~> 0.8"
  spec.add_development_dependency "terminal-table", "~> 1.7"
end
