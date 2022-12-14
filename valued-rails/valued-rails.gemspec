require_relative "../lib/gemspec"

Gemspec.new do |spec|
  spec.summary = "Rails plugin for event tracking with Valued"
  spec.add_dependency "rails", "~> 7.0"
end
