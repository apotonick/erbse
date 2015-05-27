module Erbse
  # Compiles the runtime method for an ERB input string.
  class Template
    def initialize(input, properties={})
      generator = RubyGenerator.new
      converter = Basic::Converter.new(properties, generator)
      @src      = converter.call(input)
    end

    def call
      @src
    end
  end
end
