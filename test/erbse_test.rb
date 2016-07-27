require "test_helper"

# most tests are via cells-erb.

class ErbseTest < MiniTest::Spec
  it do
    Erbse::Template.new(%{<%- text = "Hello" %> <%= text %>}).call.must_equal "@output_buffer = output_buffer; text = \"Hello\" ;@output_buffer.safe_append=' '.freeze;@output_buffer.append=( text ).to_s;@output_buffer.to_s"
  end

  # nested <%= block do %> syntax.
  it do
    Erbse::Template.new(%{<%= form_for do %><%= content_tag :div do %>DIV<% end %><% end %>}).call.must_equal "@output_buffer = output_buffer;@output_buffer.append=  form_for do @output_buffer.append=  content_tag :div do @output_buffer.safe_append='DIV'.freeze; end ; end ;@output_buffer.to_s"
  end

  it "calls (block).to_s" do
    Erbse::Template.new(%{<%= f.input %>}).call.must_equal %{@output_buffer = output_buffer;@output_buffer.append=( f.input ).to_s;@output_buffer.to_s}
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
end
