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

    def add_preamble(src, buffer_name)
      @newline_pending = 0
      # src << "@output_buffer = output_buffer;" # DISCUSS: i removed the output_buffer || ActionView::OB.new rubbish here.
      src << "#{buffer_name} = '';"
    end

    def add_text(src, text, buffer_name)
      return if text.empty?

      if text == "\n"
        @newline_pending += 1
      else
        # src << "@output_buffer.safe_append='"
        src << "#{buffer_name} << '"
        src << "\n" * @newline_pending if @newline_pending > 0
        src << escape_text(text)
        src << "'.freeze;"

        @newline_pending = 0
      end
    end

    # if, method do, and so on, assignments
    # <% .. >
    def add_stmt(src, code, buffer_name)
      flush_newline_if_pending(src)

      src << code
      src << ';' unless code[-1] == ?\n
    end

    BLOCK_EXPR = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

    # <%= .. [do] >
    def add_expr_literal(src, code, indicator, buffer_name, buffer_i)
      flush_newline_if_pending(src)
      if code =~ BLOCK_EXPR
        src << ";#{buffer_name}= " << code

        src << "; ob_#{buffer_i}='';"
      else
        src << ";#{buffer_name}<< (" << code << ').to_s;'
      end
    end

    def add_postamble(src, buffer_name)
      flush_newline_if_pending(src)
      src << "#{buffer_name}.to_s"
    end

    def flush_newline_if_pending(src)
      if @newline_pending > 0
        #src << "@output_buffer.safe_append='#{"\n" * @newline_pending}'.freeze;"
        @newline_pending = 0
      end
    end
  end
end
