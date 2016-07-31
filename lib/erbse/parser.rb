module Erbse
  class Parser
    # DEFAULT_REGEXP = /<%(=+|-|\#|%)?(.*?)([-=])?%>([ \t]*\r?\n)?/m
    DEFAULT_REGEXP = /<%(=|\#)?(.*?)%>([ \t]*\r?\n)?/m
    BLOCK_EXPR     = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

    def initialize(*)
    end

    def call(str)
      pos = 0

      buffers = []
      result = [:multi]
      buffers << result

      index = 0

      str.scan(DEFAULT_REGEXP) do |indicator, code|
        match = Regexp.last_match()
        len  = match.begin(0) - pos
        text = str[pos, len]
        pos  = match.end(0)
        ch   = indicator ? indicator[0] : nil

        result = buffers.last
        if text and text.strip != ""
          buffers.last << [:static, text]
        end

        if ch == ?= # <%= %>
          if code =~ BLOCK_EXPR
            buffers.last << [:erb, :block, index += 1, index += 1, code, block = [:multi]]
            buffers << block
          else
            buffers.last << [:dynamic, code]
          end
        else # <% %>
          if code =~ / end /
            block = buffers.pop
            next
          end

          buffers.last << [:code, code]
        end



        #     generator.add_expr_literal(src, code, indicator, "ob_#{top_buffer}", buffers)

        #   elsif ch == ?\#                                                                       # <%# %>
        #     n = code.count("\n") + (rspace ? 1 : 0)
        #     if @trim && lspace && rspace
        #       generator.add_stmt(src, "\n" * n, "ob_#{buffers.size}")
        #     else
        #       generator.add_stmt(src, "\n" * n, "ob_#{buffers.size}")
        #     end
      end

      buffers.last
    end
  end
end
