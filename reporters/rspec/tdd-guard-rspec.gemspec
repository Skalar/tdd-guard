Gem::Specification.new do |spec|
  spec.name          = "tdd-guard-rspec"
  spec.version       = "0.1.0"
  spec.authors       = ["TDD Guard"]
  spec.summary       = "RSpec reporter for TDD Guard"
  spec.description   = "An RSpec formatter that outputs test results in TDD Guard's JSON format"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec", ">= 3.0"
end
