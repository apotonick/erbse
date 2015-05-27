require "test_helper"
require 'ruby-prof'

  def output_buffer
    OB.new
  end

  def capture(&block)
    # in the "old style" we have to switch output buffers
    # here, we can execute the block in a different environment. disgusting.
    old = @output_buffer
    @output_buffer = OB.new
    yield

    value = @output_buffer
    @output_buffer = old
    value
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


  string = %{Yeah
  <% outer = "Outer" %>
  <% res = capture do %>
    Inside.
    <%= outer %>
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

precompiled = Erbse::Template.new(string).call

  RubyProf.start

  100000.times do
    eval(precompiled)
  end

  res = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(res)
  puts "roar:"
  printer.print(STDOUT)

