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
      [:dynamic, " true "], [:newline],
      [:static, "Text\n"],
      [:erb, :block, " form_for do ", [:multi,
        [:dynamic, " 1 "],
        [:code, " 2 "], [:newline],
        [:erb, :block, " nested do ", [:multi, [:newline],
          [:dynamic, " this "], [:newline],
          [:static, "    <a/>\n  "],
          ]], [:newline]]]]
  end

  it "generates ruby" do
      code = %{_buf = []; _buf << ( true ); @; _buf << ("Text@@".freeze); _erbse_blockfilter1 =  form_for do ; _erbse_blockfilter2 = ''; _erbse_blockfilter2 << (( 1 ).to_s);  2 ; @; _erbse_blockfilter3 =  nested do ; _erbse_blockfilter4 = ''; @; _erbse_blockfilter4 << (( this ).to_s); @; _erbse_blockfilter4 << ("    <a/>@@  ".freeze); _erbse_blockfilter4; end; _erbse_blockfilter2 << ((_erbse_blockfilter3).to_s); @; _erbse_blockfilter2; end; _buf << (_erbse_blockfilter1); _buf = _buf.join("".freeze)}
    ruby = Erbse::Engine.new.(str).gsub("\n", "@").gsub('\n', "@@")
    # puts ruby
    ruby.must_equal code
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
      Erbse::Parser.new.(str).must_equal [:multi,
        [:code, " self "], [:newline],
        [:block, " 2.times do |i| ", [:multi, [:newline],
          [:dynamic, " i+1 "], [:newline],
          [:code, " puts "], [:newline]]], [:newline],
        [:block, " if 1 ", [:multi, [:newline],
          [:static, "  Hello
"]]], [:newline]]
    end

    it do
      ruby = Erbse::Engine.new.(str)
      ruby = ruby.gsub("\n", "@")

      # ruby.must_equal %{_buf = [];  self ;  2.times do |i| ; _buf << ( i+1 );  puts ; end; _buf = _buf.join(\"\".freeze)}
      ruby.must_equal '_buf = [];  self ; @;  2.times do |i| ; @; _buf << ( i+1 ); @;  puts ; @; end; @;  if 1 ; @; _buf << ("  Hello\n".freeze); end; @; _buf = _buf.join("".freeze)'
    end

    it do
      ruby = Erbse::Engine.new.(str)
      eval(ruby).must_equal "12  Hello\n"
    end
  end

  describe "pure text" do
    let (:str) { %{Holla
Hi}
    }
    it "what" do
      Erbse::Parser.new.(str).must_equal [:multi, [:static, "Holla\nHi"]]
    end
  end

  describe "<%# this %>" do
    let (:str) { %{Hello
<%# Ignore this %>
Hola
<%# Ignore
this %>
Hi
<% # this %>
      } }

    it do
      Erbse::Parser.new.(str).must_equal [:multi, [:static, "Hello\n"], [:newline], [:static, "Hola\n"], [:newline], [:newline], [:static, "Hi\n"], [:code, " # this "], [:newline]]
    end

    it "what" do
      ruby = Erbse::Engine.new.(str).gsub("\n", "@").gsub('\n', "@@")
      code = %{_buf = []; _buf << ("Hello@@".freeze); @; _buf << ("Hola@@".freeze); @; @; _buf << ("Hi@@".freeze);  # this ; @; _buf = _buf.join("".freeze)}
      ruby.must_equal code
    end
  end

  describe "multiple tags in one row" do
    let (:str) { %{<b><%= 1 %></b>} }

    it do
      Erbse::Parser.new.(str).must_equal []
    end

  end
end
