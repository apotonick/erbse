require "test_helper"

# most tests are via cells-erb.

class ErbseTest < MiniTest::Spec
  it do
    Erbse::Template.new(%{<%- text = "Hello" %> <%= text %>}).call.must_equal "@output_buffer = output_buffer; text = \"Hello\" ;@output_buffer.safe_append=' '.freeze;@output_buffer.append=( text );@output_buffer.to_s"
  end

  # nested <%= block do %> syntax.
  it do
    Erbse::Template.new(%{<%= form_for do %><%= content_tag :div do %>DIV<% end %><% end %>}).call.must_equal "@output_buffer = output_buffer;@output_buffer.append=  form_for do @output_buffer.append=  content_tag :div do @output_buffer.safe_append='DIV'.freeze; end ; end ;@output_buffer.to_s"
  end

  # performance optimizations.
  it do
    Erbse::Template.new(%{<b>Cool</b>
     some text

<b> Even cooler!</b>

  <% call_me %>s
}).call.must_equal %{@output_buffer = output_buffer;@output_buffer.safe_append='<b>Cool</b>
     some text

<b> Even cooler!</b>

'.freeze;@output_buffer.safe_append='  '.freeze; call_me ;@output_buffer.safe_append='s
'.freeze;@output_buffer.to_s}
  end


  # play around with capture.
  it do
    string = %{Yeah
  <% outer = "Outer" %>
  <% res = capture do %>
    Inside.
    <% outer %>
    <%= method_call %>
    *<% res2 = capture do %>between stars<%end%>*
    Still Inside.<%= res2 %>
  <% end %> >cap <%= res %> }

    puts "appending"
    puts Erbse::Template.new(string).call

#     @output_buffer = output_buffer;@output_buffer.safe_append='Yeah '.freeze; res = capture do ;@output_buffer.safe_append='
#   Inside.
# '.freeze; end ;@output_buffer.safe_append=' '.freeze;@output_buffer.to_s

#   puts "@@@@@ #{@output_buffer}"

  puts eval(Erbse::Template.new(string).call)


end

 it do


  @output_buffer = output_buffer;

  puts "interpolate"
 puts  "Yeah
  #{outer = "Outer"; nil}
  #{res = capture do
    "Inside.
    #{outer}
    #{method_call}
    *#{res2 = capture do "between stars" end;nil}*
    Still Inside. *#{res2}*"
  end;nil } >cap; #{res} "


#   @output_buffer.safe_append='Yeah '.freeze; res = capture do ;@output_buffer.safe_append='
#   Inside.
#   '.freeze;@output_buffer.append=( method_call );@output_buffer.safe_append='
#   Still Inside.
# '.freeze; end ;@output_buffer.safe_append=' '.freeze;@output_buffer.to_s


puts

  end

  def output_buffer
    OB.new
  end

  def capture(&block)
    # in the "old style" we have to switch output buffers
    # here, we can execute the block in a different environment. disgusting.
    yield
  end

  def method_call
    "Yo!"
  end

  class OB < String
    # def safe_append=(str) # alias_method will be faster.
    #   self << str
    # end
    alias_method :safe_append=, :<<
    alias_method :append=, :<<

  end




  class InterpolatedGenerator
    def add_preamble(src)
      src << %{"}
    end

    def add_postamble(src)
      src << %{"}
    end

    def add_text(src, text)
      src << text
    end

    BLOCK_EXPR = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/
    END_EXPR = /end/ # FIXME.

    def add_stmt(src, statement)
      if statement =~ BLOCK_EXPR # res2 = capture do
        src << '#{' + statement + '"'
      elsif statement =~ END_EXPR # "end"
        src << '"' + statement + '; nil}' # FIXME: add nil only when not %=
      else # outer = \"Outer\" \n"
        src << '#{' + statement + '; nil}'
        puts "@@@@@ #{statement.inspect}"
      end

      # puts statement
      # src << %{text\n}
    end

    def add_expr_literal(src, expr)
      puts "@@@@@ #{expr.inspect}"
      # puts expr
      src << '#{' + expr + '}'
    end

    # def ____add_stmt(src, code)
    #   src << code
    #   src << ';' unless code[-1] == ?\n
    # end
  end

  # TODO <%= form_for do |f| %>
  it "interpolated" do
      string = %{Yeah
  <% outer = "Outer" %>
  <% res = capture do %>
    Inside.
    <%= outer %> <% "I should never appear" %> <%= "show me!" %>
    <%= method_call %>
    *<% res2 = capture do %>between stars<%end%>*
    Still Inside.<%= res2 %>
  <% end %> >cap <%= res %> }


    generator = InterpolatedGenerator.new
      converter = Erbse::Basic::Converter.new({}, generator)
    puts precompiled = converter.call(string)


    puts "~~~~~~~~~"
    puts eval(precompiled)
  end
end