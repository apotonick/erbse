module Erbse
  # Convert input ERB string into Ruby.
  class Parser
    def initialize(properties={}, generator)
      init_converter!(properties)
      @generator = generator
    end

    def call(input)
      codebuf = ""    # or []
      @preamble.nil? ? generator.add_preamble(codebuf) : (@preamble && (codebuf << @preamble))
      convert_input(codebuf, input)
      @postamble.nil? ? generator.add_postamble(codebuf) : (@postamble && (codebuf << @postamble))
      return codebuf  # or codebuf.join()
    end

  private
    attr_accessor :preamble, :postamble, :escape

    attr_reader :generator

    def init_converter!(properties)
      @preamble  = properties[:preamble]
      @postamble = properties[:postamble]
      @escape    = properties[:escape]
    end

    ##
    ## detect spaces at beginning of line
    ##
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


  module Basic
  end


  ##
  ## basic converter which supports '<% ... %>' notation.
  ##
  class Basic::Parser < Parser
    def self.supported_properties    # :nodoc:
      return [
              [:pattern,  '<% %>', "embed pattern"],
              [:trim,      true,   "trim spaces around <% ... %>"],
             ]
    end


  private

    attr_accessor :pattern, :trim

    def init_converter!(properties={})
      super(properties)
      @pattern = properties[:pattern]
      @trim    = properties[:trim] != false
    end



    ## return regexp of pattern to parse eRuby script
    def self.pattern_regexp(pattern)
      @prefix, @postfix = pattern.split()   # '<% %>' => '<%', '%>'
      return /#{@prefix}(=+|-|\#|%)?(.*?)([-=])?#{@postfix}([ \t]*\r?\n)?/m
    end

    DEFAULT_REGEXP = pattern_regexp('<% %>')

    def convert_input(src, input)
      pat = @pattern
      regexp = pat.nil? || pat == '<% %>' ? DEFAULT_REGEXP : pattern_regexp(pat)
      pos = 0
      is_bol = true     # is beginning of line
      input.scan(regexp) do |indicator, code, tailch, rspace|
        match = Regexp.last_match()
        len  = match.begin(0) - pos
        text = input[pos, len]
        pos  = match.end(0)
        ch   = indicator ? indicator[0] : nil
        lspace = ch == ?= ? nil : detect_spaces_at_bol(text, is_bol)
        is_bol = rspace ? true : false
        generator.add_text(src, text) if text && !text.empty?
        ## * when '<%= %>', do nothing
        ## * when '<% %>' or '<%# %>', delete spaces iff only spaces are around '<% %>'
        if ch == ?=              # <%= %>
          rspace = nil if tailch && !tailch.empty?
          generator.add_text(src, lspace) if lspace
          add_expr(src, code, indicator)
          generator.add_text(src, rspace) if rspace
        elsif ch == ?\#          # <%# %>
          n = code.count("\n") + (rspace ? 1 : 0)
          if @trim && lspace && rspace
            generator.add_stmt(src, "\n" * n)
          else
            generator.add_text(src, lspace) if lspace
            generator.add_stmt(src, "\n" * n)
            generator.add_text(src, rspace) if rspace
          end
        elsif ch == ?%           # <%% %>
          s = "#{lspace}#{@prefix||='<%'}#{code}#{tailch}#{@postfix||='%>'}#{rspace}"
          generator.add_text(src, s)
        else                     # <% %>
          if @trim && lspace && rspace
            generator.add_stmt(src, "#{lspace}#{code}#{rspace}")
          else
            generator.add_text(src, lspace) if lspace
            generator.add_stmt(src, code)
            generator.add_text(src, rspace) if rspace
          end
        end
      end
      #rest = $' || input                        # ruby1.8
      rest = pos == 0 ? input : input[pos..-1]   # ruby1.9
      generator.add_text(src, rest)
    end

    ## add expression code to src
    def add_expr(src, code, indicator)
      case indicator
      when '='
        generator.add_expr_literal(src, code, indicator)
      when '=='
        generator.add_expr_literal(src, code, indicator)
      end
    end
  end
end
