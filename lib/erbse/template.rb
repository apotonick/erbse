module Erbse
  # Compiles the runtime method for an ERB input string.
  class Template
    def initialize(input, properties={})
      generator = RubyGenerator.new
      parser    = Basic::Parser.new(properties, generator)
      @src      = parser.call(input)
    end

    def call
      @src
    end
  end
end
