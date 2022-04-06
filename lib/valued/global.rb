module Valued::Global
  attr_accessor :connection

  def connect(...)
    self.connection = Valued::Connection.new(...)
    @scope_store = Concurrent::ThreadLocalVar.new(connection)
  end

  def scope(**options, &block)
    raise RuntimeError, "call connect first" unless connection
    scope = @scope_store.value

    if options.any?
      scope = scope.scope(**options)
      return @scope_store.bind(scope, &block) if block
      @scope_store.value = scope
    else
      block ? yield : scope
    end
  end

  def track(...) = scope.track(...)
end