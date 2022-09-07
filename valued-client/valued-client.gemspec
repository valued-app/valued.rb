require_relative "../lib/gemspec"

Gemspec.new do |spec|
  spec.summary = "Ruby client for event tracking with Valued"
  spec.add_dependency "concurrent-ruby", "~> 1.1"
end
