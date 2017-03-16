# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcodebot/version'

Gem::Specification.new do |spec|
  spec.name          = "xcodebot"
  spec.version       = Xcodebot::VERSION
  spec.authors       = ["j2shnz"]
  spec.email         = ["jessy.hanzo@gmail.com"]

  spec.summary       = %q{Run xcode bots}
  spec.description   = %q{Xcodebot helps you to manage xcode bots easier}
  spec.homepage      = "https://github.com/j2shnz/xcodebot"
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
  spec.add_development_dependency "rconfig", "~> 0.5.4"
  spec.add_development_dependency "highline", "~> 1.7.8"
end
