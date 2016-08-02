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

      str.scan(DEFAULT_REGEXP) do |indicator, code|
        match = Regexp.last_match()
        len  = match.begin(0) - pos
        text = str[pos, len]
        pos  = match.end(0)
        ch   = indicator ? indicator[0] : nil

        if text and !text.strip.empty? # text
          buffers.last << [:static, text]
        end

        if ch == ?= # <%= %>
          if code =~ BLOCK_EXPR
            buffers.last << [:erb, :block, code, block = [:multi]] # picked up by our own BlockFilter
            buffers << block
          else
            buffers.last << [:dynamic, code]
          end
        else # <% %>
          if code =~ / end /
            buffers.pop
            next
          end

          if code =~ BLOCK_EXPR
            buffers.last << [:block, code, block = [:multi]] # picked up by Temple's ControlFlow filter.
            buffers << block
          else
            buffers.last << [:code, code]
          end
        end

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
