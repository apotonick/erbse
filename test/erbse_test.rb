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
end