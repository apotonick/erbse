require "test_helper"

#ob_0 = '';;ob_0<< ( true ).to_s;ob_0 << ' '.freeze;;ob_1 =  form_for do ; ob_2='';;ob_2<< ( 1 ).to_s;;ob_2<< ( 2 ).to_s;;ob_3 =  nested do ; ob_4='';;ob_4<< ( 3 ).to_s;;ob_4<< ( 4 ).to_s;ob_4; end ;ob_2 << ob_3;ob_3; end ;ob_1 << ob_2;ob_0.to_s


describe "AST" do
  let (:str) { %{
<%= true %>
Text
<%= form_for do %><%= 1 %><% 2 %>
  <%= nested do %>
    <%= this %>
    <a/>
  <% end %>
<% end %>}
}

  it "what" do
    Erbse::Parser.new.(str).must_equal [:multi,
      [:dynamic, " true "],
      [:static, "Text\n"],
      [:erb, :block, 1, 2, " form_for do ", [:multi,
        [:dynamic, " 1 "],
        [:code, " 2 "],
        [:erb, :block, 3, 4, " nested do ", [:multi,
          [:dynamic, " this "],
          [:static, "    <a/>\n  "],
          ]]]]]
  end

  it "generates ruby" do
    Erbse::Engine.
      new().
      (str).must_equal "_buf = [];  true ; _erbse_blockfilter1 =  form_for do ; _erbse_blockfilter2 = '';  1 ;  2 ; _erbse_blockfilter3 =  nested do ; _erbse_blockfilter4 = '';  this ; _erbse_blockfilter4; end; _erbse_blockfilter2 << ((_erbse_blockfilter3).to_s); _erbse_blockfilter2; end; _buf << (_erbse_blockfilter1); _buf = _buf.join(\"\".freeze)"
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

past = [:multi, [:code, " true "], [:erb, :block, 1, 2, " form_for do ", [:multi, [:dynamic, " 1 "], [:code, " 2 "], [:erb, :block, 3, 4, " nested do ", [:multi, [:dynamic, " this "]]]]]]
module Erbse

end

block_ast = Erbse::BlockFilter.new.(past)
puts block_ast.inspect

past = Temple::Filters::ControlFlow.new().call(block_ast)
puts Temple::Generators::ArrayBuffer.new.(past)
puts

# _buf = []; ob_1 = ''; loop do; ob_1 << ("Hello".freeze); end; ob_1; _buf = _buf.join("".freeze)

past = [:multi, [:block, "ob_1 = "+"loop do", [:capture, "ob_2", [:multi, [:static, "Hello"]]]], [:dynamic, "ob_1"]]
past = Temple::Filters::ControlFlow.new().call(past)

puts Temple::Generators::ArrayBuffer.new.(past)


# core abstraction: multi, static, dynamic, code, newline and capture
