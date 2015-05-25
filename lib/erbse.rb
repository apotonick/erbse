##
## an implementation of eRuby
##
## ex.
##   input = <<'END'
##    <ul>
##     <% for item in @list %>
##      <li><%= item %>
##          <%== item %></li>
##     <% end %>
##    </ul>
##   END
##   list = ['<aaa>', 'b&b', '"ccc"']
##   eruby = Erubis::Eruby.new(input)
##   puts "--- code ---"
##   puts eruby.src
##   puts "--- result ---"
##   context = Erubis::Context.new()   # or new(:list=>list)
##   context[:list] = list
##   puts eruby.evaluate(context)
##
## result:
##   --- source ---
##   _buf = ''; _buf << '<ul>
##   ';  for item in @list
##    _buf << '  <li>'; _buf << ( item ).to_s; _buf << '
##   '; _buf << '      '; _buf << Erubis::XmlHelper.escape_xml( item ); _buf << '</li>
##   ';  end
##    _buf << '</ul>
##   ';
##   _buf.to_s
##   --- result ---
##    <ul>
##      <li><aaa>
##          &lt;aaa&gt;</li>
##      <li>b&b
##          b&amp;b</li>
##      <li>"ccc"
##          &quot;ccc&quot;</li>
##    </ul>
##


module Erbse
end

require "erbse/converter"

require "erbse/engine"
require "erbse/enhancer"

require "erbse/engine/eruby"
