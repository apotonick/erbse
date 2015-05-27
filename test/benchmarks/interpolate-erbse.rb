require "test_helper"

  def capture(&block)
    yield
  end

  def method_call
    "Yo!"
  end


require 'ruby-prof'




  string = %{Yeah
  <% outer = "Outer" %>
  <% res = capture do %>
    Inside.
    <%= outer %>
    <%= method_call %>
    *<% res2 = capture do %>between stars<%end%>*
    Still Inside.<%= res2 %>
  <% end %> >cap <%= res %> }



 precompiled =  '"Yeah
   #{outer = "Outer"; nil}
   #{res = capture do
     "
      Inside.
      #{outer}
      #{method_call}
      *#{res2 = capture do "between stars" end;nil}*
      Still Inside. *#{res2}*
    "
   end;nil } >cap; #{res} "'


  RubyProf.start

    100000.times do
      eval(precompiled)
    end

  res = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(res)
  puts "roar:"
  printer.print(STDOUT)