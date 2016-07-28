require "test_helper"

class Parser
  def self.pattern_regexp(pattern)
    @prefix, @postfix = pattern.split()   # '<% %>' => '<%', '%>'
    return /#{@prefix}(=+|-|\#|%)?(.*?)([-=])?#{@postfix}([ \t]*\r?\n)?/m
  end

  DEFAULT_REGEXP = pattern_regexp('<% %>')
  BLOCK_EXPR = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

  def call(str)
    regexp = DEFAULT_REGEXP
    pos = 0
    is_bol = true     # is beginning of line

    buffers = []
    result = [:multi]
    last_block = nil

    str.scan(regexp) do |indicator, code, tailch, rspace|
      match = Regexp.last_match()
      len  = match.begin(0) - pos
      text = str[pos, len]
      pos  = match.end(0)
      ch   = indicator ? indicator[0] : nil
      lspace = ch == ?= ? nil : detect_spaces_at_bol(text, is_bol)
      is_bol = rspace ? true : false

      puts "@@@@@ #{code.inspect}"

      if ch == ?= # <%= %>
        if code =~ BLOCK_EXPR
          result << [:block, code, block = [:multi]]
          last_block = result
          result = block
        else
          result << [:code, code]
        end
      end

      if code =~ / end /
        result = last_block
      end


      #     generator.add_expr_literal(src, code, indicator, "ob_#{top_buffer}", buffers)

      #   elsif ch == ?\#                                                                       # <%# %>
      #     n = code.count("\n") + (rspace ? 1 : 0)
      #     if @trim && lspace && rspace
      #       generator.add_stmt(src, "\n" * n, "ob_#{buffers.size}")
      #     else
      #       generator.add_stmt(src, "\n" * n, "ob_#{buffers.size}")
      #     end
      #   else

      #                                                                                 # <% %>

    end

    result
  end

  def detect_spaces_at_bol(text, is_bol)
    lspace = nil
    if text.empty?
      lspace = "" if is_bol
    elsif text[-1] == ?\n
      lspace = ""
    else
      rindex = text.rindex(?\n)
      if rindex
        s = text[rindex+1..-1]
        if s =~ /\A[ \t]*\z/
          lspace = s
          #text = text[0..rindex]
          text[rindex+1..-1] = ''
        end
      else
        if is_bol && text =~ /\A[ \t]*\z/
          #lspace = text
          #text = nil
          lspace = text.dup
          text[0..-1] = ''
        end
      end
    end
    return lspace
  end
end


str = %{<%= true %> <%= form_for do %><%= 1 %><%= 2 %><% end %>}

puts Parser.new.(str).inspect
exit

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

past = Temple::Filters::ControlFlow.new(ast)
puts past.inspect

puts Temple::Generators::ArrayBuffer.new.(ast)
