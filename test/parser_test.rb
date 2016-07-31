require "test_helper"

class Parser
  def self.pattern_regexp(pattern)
    @prefix, @postfix = pattern.split()   # '<% %>' => '<%', '%>'
    return /#{@prefix}(=+|-|\#|%)?(.*?)([-=])?#{@postfix}([ \t]*\r?\n)?/m
  end

  DEFAULT_REGEXP = pattern_regexp('<% %>')
  BLOCK_EXPR = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

  def call(str)
    pos = 0
    is_bol = true     # is beginning of line

    buffers = []
    result = [:multi]
    buffers << result

    index = 0

    str.scan(DEFAULT_REGEXP) do |indicator, code, tailch, rspace|
      match = Regexp.last_match()
      len  = match.begin(0) - pos
      text = str[pos, len]
      pos  = match.end(0)
      ch   = indicator ? indicator[0] : nil
      lspace = ch == ?= ? nil : detect_spaces_at_bol(text, is_bol)
      is_bol = rspace ? true : false

      result = buffers.last
      # puts "parsing #{code} to #{result.inspect}"

      if ch == ?= # <%= %>
        if code =~ BLOCK_EXPR
          buffers.last << [:block, index += 1, index += 1, code, block = [:multi]]
          buffers << block
        else
          buffers.last << [:code, code]
        end
      end

      if code =~ / end /
        block = buffers.pop
      end


      #     generator.add_expr_literal(src, code, indicator, "ob_#{top_buffer}", buffers)

      #   elsif ch == ?\#                                                                       # <%# %>
      #     n = code.count("\n") + (rspace ? 1 : 0)
      #     if @trim && lspace && rspace
      #       generator.add_stmt(src, "\n" * n, "ob_#{buffers.size}")
      #     else
      #       generator.add_stmt(src, "\n" * n, "ob_#{buffers.size}")
      #     end
      #   else

      #                                                                                 # <% %>

    end

    buffers.last
  end

  def detect_spaces_at_bol(text, is_bol)
    lspace = nil
    if text.empty?
      lspace = "" if is_bol
    elsif text[-1] == ?\n
      lspace = ""
    else
      rindex = text.rindex(?\n)
      if rindex
        s = text[rindex+1..-1]
        if s =~ /\A[ \t]*\z/
          lspace = s
          #text = text[0..rindex]
          text[rindex+1..-1] = ''
        end
      else
        if is_bol && text =~ /\A[ \t]*\z/
          #lspace = text
          #text = nil
          lspace = text.dup
          text[0..-1] = ''
        end
      end
    end
    return lspace
  end
end


str = %{
<%= true %>
<%= form_for do %><%= 1 %><%= 2 %>
  <%= nested do %>
    <%= this %>
  <% end %>
<% end %>}.gsub("\n","")

puts Parser.new.(str).inspect

first = Parser.new.(str)

require "temple"
class Filter < Temple::Filter
  define_options :key

  def on_block(arg)
    raise arg
  end
end

class SimpleFilter < Temple::Filter
  define_options :key

  def on_code(*args)

    [:on_test, args]
  end
end

puts first.inspect
# puts Filter.new.call(first)
res = SimpleFilter.new.call([:multi, [:code, 1], [:code, 2]])
puts res.inspect


#ob_0 = '';;ob_0<< ( true ).to_s;ob_0 << ' '.freeze;;ob_1 =  form_for do ; ob_2='';;ob_2<< ( 1 ).to_s;;ob_2<< ( 2 ).to_s;;ob_3 =  nested do ; ob_4='';;ob_4<< ( 3 ).to_s;;ob_4<< ( 4 ).to_s;ob_4; end ;ob_2 << ob_3;ob_3; end ;ob_1 << ob_2;ob_0.to_s


describe "AST" do
  let (:str) { %{
<%= true %>
<%= form_for do %><%= 1 %><%= 2 %>
  <%= nested do %>
    <%= this %>
  <% end %>
<% end %>}.gsub("\n","")
}

  it "what" do
    Parser.new.(str).must_equal [:multi, [:code, " true "], [:block, 1, 2, " form_for do ", [:multi, [:code, " 1 "], [:code, " 2 "], [:block, 3, 4, " nested do ", [:multi, [:code, " this "]]]]]]
  end
end

# exit

ast=
[:multi,
  [:static, true],
  [:block, "form_for do", [:multi,
      [:code, 1]
    ]
  ],
  [:dynamic, "1+1"]
]

require "temple"

past = Temple::Filters::ControlFlow.new().call([:block, 'loop do',
      [:static, 'Hello']])
puts past.inspect


past = [:multi, [:code, "loop do"], [:static, "Hello"], [:code, "end"]]

past = [:multi, [:code, " true "], [:erb, :block, 1, 2, " form_for do ", [:multi, [:code, " 1 "], [:code, " 2 "], [:erb, :block, 3, 4, " nested do ", [:multi, [:code, " this "]]]]]]
class BlockFilter < Temple::Filter
  define_options :key

  # Highly inspired by https://github.com/slim-template/slim/blob/master/lib/slim/controls.rb#on_slim_output
  def on_erb_block(outter_i, inner_i, code, content_ast)
    # this is for <%= do %>
    outter_i = unique_name
    inner_i  = unique_name

    # this still needs the Temple::Filters::ControlFlow run-through.
    [:multi,
      [:block, "#{outter_i} = #{code}", compile(content_ast)], # compile() is recursion on nested block content.
      [:dynamic, outter_i] # return the outter buffer. # DISCUSS: why do we need that, again?
    ]
  end
end
puts BlockFilter.new.(past).inspect


# _buf = []; ob_1 = ''; loop do; ob_1 << ("Hello".freeze); end; ob_1; _buf = _buf.join("".freeze)

past = [:multi, [:block, "ob_1 = "+"loop do", [:capture, "ob_2", [:multi, [:static, "Hello"]]]], [:dynamic, "ob_1"]]
past = Temple::Filters::ControlFlow.new().call(past)

puts Temple::Generators::ArrayBuffer.new.(past)


# core abstraction: multi, static, dynamic, code, newline and capture
