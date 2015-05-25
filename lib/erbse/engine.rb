require 'erbse/context'


module Erbse
  ## (abstract) abstract engine class.
  ## subclass must include evaluator and converter module.
  ##
  class Engine
    def initialize(input, properties={})
      generator = RubyGenerator.new
      converter = Basic::Converter.new(properties, generator)
      @src       = converter.convert(input)
    end

    attr_reader :src # TODO: rename to #call.
  end


  class Eruby < Engine
    # include RubyGenerator
  end
end
