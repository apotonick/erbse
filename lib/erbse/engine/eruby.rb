module Erbse
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

    #--
    #def add_preamble(src)
    #  src << "#{@bufvar} = [];"
    #end
    #++
    def add_preamble(src)
      @newline_pending = 0
      src << "@output_buffer = output_buffer;" # DISCUSS: i removed the output_buffer || ActionView::OB.new rubbish here.
    end

    # def add_text(src, text)
    #   src << " #{@bufvar} << '" << escape_text(text) << "';" unless text.empty?
    # end
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

    # Erubis toggles <%= and <%== behavior when escaping is enabled.
    # We override to always treat <%== as escaped.
    # def add_expr(src, code, indicator)
    #   case indicator
    #   when '=='
    #     add_expr_escaped(src, code)
    #   else
    #     super
    #   end
    # end

    def ____add_stmt(src, code)
      #src << code << ';'
      src << code
      src << ';' unless code[-1] == ?\n
    end

    def add_stmt(src, code)
      flush_newline_if_pending(src)
      ____add_stmt(src, code)
    end

    # def add_expr_literal(src, code)
    #   src << " #{@bufvar} << (" << code << ').to_s;'
    # end
    BLOCK_EXPR = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

    def add_expr_literal(src, code)
      flush_newline_if_pending(src)
      if code =~ BLOCK_EXPR
        src << '@output_buffer.append= ' << code
      else
        src << '@output_buffer.append=(' << code << ');'
      end
    end

    def add_expr_escaped(src, code)
      flush_newline_if_pending(src)
      if code =~ BLOCK_EXPR
        src << "@output_buffer.safe_expr_append= " << code
      else
        src << "@output_buffer.safe_expr_append=(" << code << ");"
      end
    end

    # def add_expr_escaped(src, code)
    #   src << " #{@bufvar} << " << escaped_expr(code) << ';'
    # end

    def add_expr_debug(src, code)
      code.strip!
      s = (code.dump =~ /\A"(.*)"\z/) && $1
      src << ' $stderr.puts("*** debug: ' << s << '=#{(' << code << ').inspect}");'
    end

    #--
    #def add_postamble(src)
    #  src << "\n#{@bufvar}.join\n"
    #end
    #++
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
