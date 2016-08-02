require "test_helper"

#ob_0 = '';;ob_0<< ( true ).to_s;ob_0 << ' '.freeze;;ob_1 =  form_for do ; ob_2='';;ob_2<< ( 1 ).to_s;;ob_2<< ( 2 ).to_s;;ob_3 =  nested do ; ob_4='';;ob_4<< ( 3 ).to_s;;ob_4<< ( 4 ).to_s;ob_4; end ;ob_2 << ob_3;ob_3; end ;ob_1 << ob_2;ob_0.to_s

class ErbseTest < Minitest::Spec
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
      [:erb, :block, " form_for do ", [:multi,
        [:dynamic, " 1 "],
        [:code, " 2 "],
        [:erb, :block, " nested do ", [:multi,
          [:dynamic, " this "],
          [:static, "    <a/>\n  "],
          ]]]]]
  end

  it "generates ruby" do
    code = %{_buf = []; _buf << ( true ); _buf << ("Text\n".freeze); _erbse_blockfilter1 =  form_for do ; _erbse_blockfilter2 = ''; _erbse_blockfilter2 << (( 1 ).to_s);  2 ; _erbse_blockfilter3 =  nested do ; _erbse_blockfilter4 = ''; _erbse_blockfilter4 << (( this ).to_s); _erbse_blockfilter4 << ("    <a/>\n  ".freeze); _erbse_blockfilter4; end; _erbse_blockfilter2 << ((_erbse_blockfilter3).to_s); _erbse_blockfilter2; end; _buf << (_erbse_blockfilter1); _buf = _buf.join("".freeze)}
    # puts Erbse::Engine.new().(str)
    Erbse::Engine.new.(str).must_equal code
  end

  describe "<% %>" do
    let (:str) { %{
<% self %>
<% 2.times do |i| %>
  <%= i+1 %>
  <% puts %>
<% end %>

<% if 1 %>
  Hello
<% end %>
}
    }
    it "what" do
      Erbse::Parser.new.(str).must_equal [:multi, [:code, " self "], [:block, " 2.times do |i| ", [:multi, [:dynamic, " i+1 "], [:code, " puts "]]], [:block, " if 1 ", [:multi, [:static, "  Hello
"]]]]
    end

    it do
      ruby = Erbse::Engine.new.(str)
      # ruby.must_equal %{_buf = [];  self ;  2.times do |i| ; _buf << ( i+1 );  puts ; end; _buf = _buf.join(\"\".freeze)}
      ruby.must_equal %{_buf = [];  self ;  2.times do |i| ; _buf << ( i+1 );  puts ; end;  if 1 ; _buf << (\"  Hello
 \".freeze); end; _buf = _buf.join(\"\".freeze)}
    end

    it do
      ruby = Erbse::Engine.new.(str)
      eval(ruby).must_equal "12  Hello\n"
    end
  end

  describe "pure text" do
    let (:str) { %{Hola
Hi}
    }
    it "what" do
      Erbse::Parser.new.(str).must_equal [:multi, [:static, "Hola\nHi"]]
    end

    it do
      ruby = Erbse::Engine.new.(str)
      # ruby.must_equal %{_buf = [];  self ;  2.times do |i| ; _buf << ( i+1 );  puts ; end; _buf = _buf.join(\"\".freeze)}
    end
  end
end
