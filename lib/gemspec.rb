# @see Gemspec.new
module Gemspec
  VERSION = File.read("#{__dir__}/../VERSION").strip
  
  # Helper method to generate a new gemspec.
  def self.new(name: File.basename(Dir.pwd), version: VERSION, **options)
    Gem::Specification.new(name, version) do |spec|
      # Set the default attributes
      spec.author                = "Highly Valued, Inc."
      spec.email                 = "hello@valued.app"
      spec.homepage              = "https://valued.app"
      spec.files                 = Dir["lib/**/*", "README.md"]
      spec.required_ruby_version = "~> 3.0"
      spec.metadata              = {
        'homepage_uri'           => spec.homepage,
        'source_code_uri'        => "https://github.com/valued-app/valued.rb/tree/main/#{name}",
        'bug_tracker_uri'        => "https://github.com/valued-app/valued.rb/issues",
        'documentation_uri'      => "https://www.rubydoc.info/gems/#{name}"
      }
  
      # Depend on valued-client (except for valued-client itself)
      spec.add_runtime_dependency "valued-client", VERSION if name != "valued-client"

      # apply all options
      options.each { spec.send("#{_1}=", _2) }
  
      yield spec if block_given?
    end
  end
end