# frozen_string_literal: true

require "rails"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.inflector.inflect("valued-rails" => "Valued", "dsl" => "DSL")
loader.ignore("#{__dir__}/generators")
loader.setup

require "valued"
require "valued/rails/railtie"