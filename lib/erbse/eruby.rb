module Erbse
  # Gets called by the converter for patterns.
  class RubyGenerator
    def init_generator(properties={})
      @escapefunc ||= "Erubis::XmlHelper.escape_xml"
    end

    def escape_text(text)
      text.gsub(/['\\]/, '\\\\\&')   # "'" => "\\'",  '\\' => '\\\\'
    end

    def escaped_expr(code)
      return "#{@escapefunc}(#{code})"
    end

    def add_preamble(src)
      @newline_pending = 0
      src << "@output_buffer = output_buffer;" # DISCUSS: i removed the output_buffer || ActionView::OB.new rubbish here.
    end

    def add_text(src, text)
      return if text.empty?

      if text == "\n"
        @newline_pending += 1
      else
        src << "@output_buffer.safe_append='"
        src << "\n" * @newline_pending if @newline_pending > 0
        src << escape_text(text)
        src << "'.freeze;"

        @newline_pending = 0
      end
    end

    # if, method do, and so on, assignments
    # <% .. >
    def add_stmt(src, code)
      flush_newline_if_pending(src)

      src << code
      src << ';' unless code[-1] == ?\n
    end

    BLOCK_EXPR = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

    # <%= .. [do] >
    def add_expr_literal(src, code, indicator)
      flush_newline_if_pending(src)
      if code =~ BLOCK_EXPR
        src << '@output_buffer.append= ' << code
      else
        src << '@output_buffer.append=(' << code << ').to_s;'
      end
    end

    def add_postamble(src)
      flush_newline_if_pending(src)
      src << '@output_buffer.to_s'
    end

    def flush_newline_if_pending(src)
      if @newline_pending > 0
        src << "@output_buffer.safe_append='#{"\n" * @newline_pending}'.freeze;"
        @newline_pending = 0
      end
    end
  end
end
