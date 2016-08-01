require "temple"
require "erbse/parser"
require "erbse/template"
# require "erbse/eruby"

module Erbse
  class BlockFilter < Temple::Filter
    # Highly inspired by https://github.com/slim-template/slim/blob/master/lib/slim/controls.rb#on_slim_output
    def on_erb_block(code, content_ast)
      # this is for <%= do %>
      outter_i = unique_name
      inner_i  = unique_name

      # this still needs the Temple::Filters::ControlFlow run-through.
      [:multi,
        [:block, "#{outter_i} = #{code}",
          [:capture, inner_i, compile(content_ast)] # compile() is recursion on nested block content.
        ],
        [:dynamic, outter_i] # return the outter buffer. # DISCUSS: why do we need that, again?
      ]
    end
  end

  class Engine < Temple::Engine
    use Parser
    use BlockFilter

    # filter :MultiFlattener
    # filter :StaticMerger
    # filter :DynamicInliner
    filter :ControlFlow

   # Finally the generator
    generator :ArrayBuffer
  end

end

