# encoding: UTF-8
require_relative 'ast_node'

module Calculator
  # == The basic grammar
  #
  # The following EBNF describes the grammar that this parser handles:
  #
  # * <em>expression</em> → { <em>expression</em> ( AddOpToken | SubtractOpToken ) } <em>term</em>
  # * <em>term</em> → { <em>term</em> ( MultiplyOpToken | DivideOpToken ) } <em>factor</em>
  # * <em>factor</em> → <em>base</em> { ExponentOpToken <em>factor</em> }
  # * <em>base</em> → IntegerToken | DecimalToken | LeftParenthesisToken <em>expression</em> RightParenthesisToken
  #
  # == An LL grammar
  #
  # However, since this is a recursive-descent parser, it cannot handle the
  # above basic grammar as it is not an LL grammar.  The following EBNF is an
  # LL grammar for the above where <em>epsilon</em> is the empty string:
  #
  # * <em>expression</em> → <em>term</em> <em>expression'</em>
  # * <em>expression'</em> → <em>epsilon</em> | ( AddOpToken | SubtractOpToken ) <term> <em>expression'</em>
  # * <em>term</em> → <em>factor</em> <em>term'</em>
  # * <em>term'</em> → <em>epsilon</em> | ( MultiplyOpToken | DivideOpToken ) <factor> <em>term'</em>
  # * <em>factor</em> → <em>base</em> { ExponentOpToken <em>factor</em> }
  # * <em>base</em> → IntegerToken | DecimalToken | LeftParenthesisToken <em>expression</em> RightParenthesisToken
  #
  # == Implementation
  #
  # This a recursive descent parser where the entry method is #parse_expression.
  #
  # == Errors
  #
  # Any parse errors will result in a SyntaxError.
  #
  class Parser
    # Returns the parse tree that was generated
    attr_reader :tree

    # Parses the given token enumeration and produces a parse tree
    def initialize(tokens)
      @tokens = tokens
      @tree = parse_expression
    end

    # Returns a Graphviz representation of the tree
    def to_dot
      "digraph G {\n#{@tree.to_dot}}"
    end

    # Prints the tree to standard output in a semi-friendly manner
    def print_tree
      @tree.print_tree
    end

    private

    # Moves @tokens to the next token and return the token that was dropped
    def shift_tokens
      first = @tokens.first
      @tokens = @tokens.drop(1)
      first
    end

    # Entry point for the parser, parses an <em>expression</em>
    def parse_expression

      # TODO implement me
      def parse_expression

        ExpressionNode.new(parse_term, parse_expression_prime)
      end

      def parse_expression_prime
            case @tokens.first
              when AddOpToken
                ExpressionPrimeNode.new(shift_tokens, parse_expression_prime, parse_term)
              when SubtractOpToken
                ExpressionPrimeNode.new(shift_tokens, parse_expression_prime, parse_term)

              else
                ExpressionPrimeNode.new

            end
        def parse_term
            TermNode.new(parse_term_prime, parse_factor)



        end

        def parse_factor
            FactorNode.new(parse_term)


        end
        def parse_term_prime
                case @tokens.first
                when MultiplyOpToken
          TermPrimeNode.new(shift_tokens, parse_factor, parse_term_prime)
                when DivideOpToken
          TermPrimeNode.new(shift_tokens, parse_factor, parse_term_prime)
        else
          TermPrimeNode.new

        end


        def parse_base
          case @token.first
            when IntegerToken
              BaseNode.new(shift_tokens)
            when DecimalToken
              BaseNode.new(shift_tokens)
            else
              raise SyntaxError.new("Integer expected")
          end
        end

        end
      end
    end
  end
end
