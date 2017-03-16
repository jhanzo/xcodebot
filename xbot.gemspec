# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xbot/version'

Gem::Specification.new do |spec|
  spec.name          = "xbot"
  spec.version       = Xbot::VERSION
  spec.authors       = ["jhanzo"]
  spec.email         = ["jessy.hanzo@gmail.com"]

  spec.summary       = %q{Run xcode bots}
  spec.description   = %q{Easily run xcode bot from CLI remotely or not}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "commander", "~> 4.4.3"
  spec.add_development_dependency "colorize", "~> 0.8.1"
end

# reading list
# http://guides.rubygems.org/make-your-own-gem/
