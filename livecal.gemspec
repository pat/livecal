# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "livecal"
  spec.version       = "0.1.1"
  spec.authors       = ["Pat Allan"]
  spec.email         = ["pat@freelancing-gods.com"]

  spec.summary       = "Parses ical/ics files into a live calendar"
  spec.homepage      = "https://github.com/pat/livecal"
  spec.license       = "Hippocratic-2.1"

  spec.metadata["homepage_uri"]          = spec.homepage
  spec.metadata["source_code_uri"]       = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  # spec.metadata["changelog_uri"]   = "TODO"

  spec.required_ruby_version = ">= 2.7"

  spec.files         = Dir["lib/**/*"] + %w[LICENSE.md README.md]

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "icalendar"
  spec.add_dependency "rrule"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
end
