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
    string = %{Yeah <% res = capture do %>
  Inside.
  <%= method_call %>
  Still Inside.
<% end %> }

    puts Erbse::Template.new(string).call

    @output_buffer = output_buffer;@output_buffer.safe_append='Yeah '.freeze; res = capture do ;@output_buffer.safe_append='
  Inside.
'.freeze; end ;@output_buffer.safe_append=' '.freeze;@output_buffer.to_s

  puts "@@@@@ #{@output_buffer}"





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
    # here, we can execute the block in a different environment. disgusting.
    yield
  end

  def method_call
    "Yo!"
  end

  class OB < String
    def safe_append=(str) # alias_method will be faster.
      self << str
    end
  end
end