module Erbse
  class Parser
    def self.pattern_regexp(pattern)
      @prefix, @postfix = pattern.split()   # '<% %>' => '<%', '%>'
      return /#{@prefix}(=+|-|\#|%)?(.*?)([-=])?#{@postfix}([ \t]*\r?\n)?/m
    end

    DEFAULT_REGEXP = pattern_regexp('<% %>')
    BLOCK_EXPR = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

    def initialize(*)
    end

    def call(str)
      pos = 0
      is_bol = true     # is beginning of line

      buffers = []
      result = [:multi]
      buffers << result

      index = 0

      str.scan(DEFAULT_REGEXP) do |indicator, code, tailch, rspace|
        match = Regexp.last_match()
        len  = match.begin(0) - pos
        text = str[pos, len]
        pos  = match.end(0)
        ch   = indicator ? indicator[0] : nil
        lspace = ch == ?= ? nil : detect_spaces_at_bol(text, is_bol)
        is_bol = rspace ? true : false

        result = buffers.last
        # puts "parsing #{code} to #{result.inspect}"

        if ch == ?= # <%= %>
          if code =~ BLOCK_EXPR
            buffers.last << [:erb, :block, index += 1, index += 1, code, block = [:multi]]
            buffers << block
          else
            buffers.last << [:dynamic, code]
          end
        end

        if code =~ / end /
          block = buffers.pop
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

      buffers.last
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
end
