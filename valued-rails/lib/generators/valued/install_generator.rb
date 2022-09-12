# frozen_string_literal: true

require "rails/generators/base"

module Valued
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __dir__)
      desc "Sets up Valued and creats an initializer."

      class_option :gemfile, type: :boolean, default: true, desc: "Add optional dependencies to the Gemfile"
      class_option :initializer, type: :string, aliases: "-i", default: "short", desc: "Initializer type: short, long, or none"

      def install_dependencies
        return unless options["gemfile"]
        Bundler.gem "concurrent-ruby-ext"
      rescue Gem::LoadError
        return unless Gem.platforms.include? Gem::Platform::RUBY
        gem "concurrent-ruby-ext", "~> 1.1", comment: "Speed up concurrent-ruby with native extensions"
      end

      def create_initializer
        return if options["initializer"] == "none"
        template("initializer.rb", "config/initializers/valued.rb")
      end
    end
  end
end