require "valued"

module Valued::Helpers
  def with(...) = scope(...)

  def []=(*key, value)
    scope(key => value)
  end

  def [](*key) = scope.to_h.dig(*Valued::Data.normalize(key))
end