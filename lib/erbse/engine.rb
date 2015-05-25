require 'erbse/context'


module Erbse
  ## (abstract) abstract engine class.
  ## subclass must include evaluator and converter module.
  ##
  class Engine
    def initialize(input, properties={})
      generator = RubyGenerator.new(nil)
      converter = Basic::Converter.new(properties, generator)
      @src       = converter.convert(input)
    end

    attr_reader :src # TODO: rename to #call.


    ##
    ## convert input string and set it to @src
    ##
    def convert!(input)
      @src = convert(input)
    end


    # TODO: remove methods below here!
    ##
    ## helper method to convert and evaluate input text with context object.
    ## context may be Binding, Hash, or Object.
    ##
    def process(input, context=nil, filename=nil)
      code = convert(input)
      filename ||= '(erubis)'
      if context.is_a?(Binding)
        return eval(code, context, filename)
      else
        context = Context.new(context) if context.is_a?(Hash)
        return context.instance_eval(code, filename)
      end
    end


    ##
    ## helper method evaluate Proc object with contect object.
    ## context may be Binding, Hash, or Object.
    ##
    def process_proc(proc_obj, context=nil, filename=nil)
      if context.is_a?(Binding)
        filename ||= '(erubis)'
        return eval(proc_obj, context, filename)
      else
        context = Context.new(context) if context.is_a?(Hash)
        return context.instance_eval(&proc_obj)
      end
    end


  end


  class Eruby < Engine
    # include RubyGenerator
  end
end
