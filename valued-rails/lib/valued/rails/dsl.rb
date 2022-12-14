# frozen_string_literal: true

module Valued::Rails
  class DSL < BasicObject
    def self.run(object, block)
      return object unless block and object
      if block.arity == 0
        instance = new
        instance.instance_eval { @object = object }
        instance.instance_eval(&block)
      else
        block.call(object)
      end
      object
    end

    private

    def accepts_block?(name)
      @accepts_block ||= {}
      @accepts_block.fetch(name) do
        @accepts_block[name] =
          @object.respond_to?(name) &&
          @object.method(name).parameters.any? { _1[0] == :block }
      end
    end

    def method_for(method, arguments, block)
      return method if method.end_with? "=" or method.end_with? "?"
      return "#{method}=" if arguments.any? and @object.respond_to?("#{method}=")
      method
    end

    def method_missing(method, *arguments, &block)
      return super if method.start_with? '_' or method == :initialize
      method = method_for(method, arguments, block)
      if accepts_block?(method) or !block
        @object.public_send(method, *arguments, &block)
      else
        DSL.run(@object.public_send(method, *arguments), block)
      end
    end
  end
end