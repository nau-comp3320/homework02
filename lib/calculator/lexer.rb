# encoding: UTF-8
require 'singleton'
require_relative 'token'

module Calculator
  # Lexer enumerates all of the tokens in a given string.
  #
  # == The grammar
  #
  # The following is a formal EBNF definition of all the tokens that are tokenised by this lexer:
  #
  # * IntegerToken → [ <tt>-</tt> ] digit { digit }
  # * DecimalToken → [ <tt>-</tt> ] digit { digit } <tt>.</tt> { digit }
  # * AddOpToken → <tt>+</tt>
  # * SubtractOpToken → <tt>-</tt>
  # * MultiplyOpToken → <tt>*</tt>
  # * DivideOpToken → <tt>/</tt>
  # * ExponentOpToken → <tt>^</tt>
  # * LeftParenthesisToken → <tt>(</tt>
  # * RightParenthesisToken → <tt>)</tt>
  #
  # == Implementation
  #
  # The lexer is a discrete finite automaton.  As a result, it is logical to
  # implement it using the <em>state design pattern</em>.  Please refer to the
  # documentation of State for more information.
  #
  # == Errors
  #
  # If the lexer comes across an error state, it will raise a SyntaxError.
  #
  class Lexer
    include Enumerable

    # Creates a new lexer with the given text
    def initialize(text)
      @text = text
    end

    # Returns the next token in the input.
    def each # :yields: token
      state = DefaultState.instance
      offset = 0

      handle_result = lambda do |result|
        next_state = case result.first
                       when :accept then
                         :accept
                       when :error then
                         raise SyntaxError.new("Syntax error at offset #{offset}")
                       else
                         result.first
                     end
        result.drop(1).each do |output|
          yield output
        end
        next_state
      end

      while offset < @text.length
        c = @text[offset]
        result = case c
                   when /\s/ then
                     state.do_whitespace
                   when /\d/ then
                     state.do_digit(c)
                   when '-' then
                     state.do_hyphen
                   when '.' then
                     state.do_full_stop
                   when '+' then
                     state.do_plus
                   when '*' then
                     state.do_asterisk
                   when '/' then
                     state.do_slash
                   when '^' then
                     state.do_caret
                   when '(' then
                     state.do_left_parenthesis
                   when ')' then
                     state.do_right_parenthesis
                   else
                     raise SyntaxError.new("Unrecognized character at offset #{offset} '#{c}'")
                 end
        state = handle_result.(result)
        offset += 1
      end
      if handle_result.(state.do_end_of_input) != :accept
        raise SyntaxError.new('Unexpected end of input')
      end
    end

    private

    # Models the current state of the lexer.  Each state must implement one or
    # more of the following methods, each corresponding to an input event:
    #
    # * State#do_asterisk
    # * State#do_digit
    # * State#do_end_of_input
    # * State#do_full_stop
    # * State#do_hyphen
    # * State#do_left_parenthesis
    # * State#do_plus
    # * State#do_right_parenthesis
    # * State#do_slash
    # * State#do_whitespace
    #
    # The return value for these methods is an array where the first element is
    # one of:
    #
    # 1. The next state of the lexer, which may be <tt>self</tt>
    # 2. <tt>:accept</tt>, indicating the interpreter has successfully finished
    # 3. <tt>:error</tt>, indicating that the input is invalid for the current state
    #
    # Any additional values in the array will be considered output.  All
    # default implementations return <tt>[:error]</tt>.
    #
    class State
      # Handles a whitespace input
      def do_whitespace
        [:error]
      end

      # Handles the end of input
      def do_end_of_input
        [:error]
      end

      # Handles a digit
      def do_digit(d)
        [:error]
      end

      # Handles <tt>-</tt>
      def do_hyphen
        [:error]
      end

      # Handles <tt>.</tt>
      def do_full_stop
        [:error]
      end

      # Handles <tt>+</tt>
      def do_plus
        [:error]
      end

      # Handles <tt>*</tt>
      def do_asterisk
        [:error]
      end

      # Handles <tt>/</tt>
      def do_slash
        [:error]
      end

      # Handles <tt>^</tt>
      def do_caret
        [:error]
      end

      # Handles <tt>(</tt>
      def do_left_parenthesis
        [:error]
      end

      # Handles <tt>)</tt>
      def do_right_parenthesis
        [:error]
      end
    end

    # The primary state of the lexer.  It is not recognising any numeric
    # literals at this point.
    class DefaultState < State
      include Singleton

      def do_end_of_input
        [:accept]
      end
    end
  end
end
