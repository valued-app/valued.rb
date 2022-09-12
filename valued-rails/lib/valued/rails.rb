# frozen_string_literal: true

module Valued::Rails
  def self.setup(&block) = Setup.run(&block)
  def self.setup? = defined?(@setup) && !!@setup
end