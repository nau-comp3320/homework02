Homework 02: Creating a lexer and a parser
==========================================

For this homework assignment, you will be creating a lexer and parser for the
simple arithmetic expressions grammar you created last week.

Objectives
----------

* Gain a practical understanding of lexical and syntactic analysis by
  developing a lexer and a recursive-descent parser
* Convert a grammar into an LL grammar using left-factorisation
* Gain some experience in using [Ruby][ruby], a dynamically-typed, object-oriented
  language

[ruby]: https://www.ruby-lang.org/


Procedure
---------

### Installing Ruby

The first thing you will need to do once you have downloaded a copy of this
assignment is to install Ruby.  For this course, Ruby 1.9 or newer should work.
The [Installing Ruby][ruby-install] page is your best source of information on
how to install Ruby for your platform.  The following is drawn from that page:

* **Windows**: It seems like the best source for Ruby on Windows is [RubyInstaller][].
* **OS X**: If you have a recent version of OS X, it should have a version of
  Ruby pre-installed.  Feel free to use [Homebrew][] to get a newer version of
  Ruby.
* **Linux**: There is a good chance you already have Ruby installed.  If not,
  check your distribution documentation on how to install the Ruby package.

Note that you may wish to try to use [RubyMine][], a dedicated IDE for Ruby
development.  You can get a 30-day trial with minimal hassle or apply to get
a free student license.

[ruby-install]: https://www.ruby-lang.org/en/documentation/installation/
[RubyInstaller]: http://rubyinstaller.org/
[Homebrew]: http://brew.sh/
[RubyMine]: http://www.jetbrains.com/ruby/

### Getting around the repository

When you have checked out the homework repository, you will find the following
files:

1. A `Rakefile`, which tells the program `rake` how to do things with the
   program.  By default, if you run `rake` it will run a suite of tests to
   verify the correctness of your program.  You can also run `rake run` to run
   the program interactively.
2. You can generate documentation by running `rake rerdoc`, which will be
   placed in the `doc` directory.
3. The sources for the program are in the `lib` directory, you will be
   primarily modifying `lib/calculator/lexer.rb` and
   `lib/calculator/parser.rb`.
4. Unit tests for the program will be found in the `test` directory.  Most of
   the tests will be disabled, but you can enable them by removing the
   `DISABLED_` prefix from each test method.

### Creating the lexer

You will begin by implementing a lexical analyser for the grammar you created
in the previous homework assignment.  To do this, you will be modifying the
Lexer class in `lib/calculator/lexer.rb`.  The lexer is written using the
[state design pattern][state].

#### The grammar

The following is a formal EBNF definition of all the tokens that you will need to produce:

* IntegerToken -> [ `-` ] digit { digit }
* DecimalToken -> [ `-` ] digit { digit } `.` { digit }
* AddOpToken -> `+`
* SubtractOpToken -> `-`
* MultiplyOpToken -> `*`
* DivideOpToken -> `/`
* ExponentOpToken -> `^`
* LeftParenthesisToken -> `(`
* RightParenthesisToken -> `)`


#### Implementing the state machine

You start with an empty `DefaultState` class that inherits a `State` class. You
will need to override one or more of the `State` methods corresponding to the
events you want your state to react to.

The return value for each one of these methods is an array where the first
value is either the next state; `:accept`, indicating that the program is
accepted; or `:error` indicating that the program encountered a syntax error
(an invalid input for the given state).  Any additional elements in the array
will be considered outputs.

For example, to consume white space, you can add the following method:

```ruby
class DefaultState < State
  def do_whitespace
    [self]
  end
end
```

To handle a `+` character as an `AddOpToken`, you can do:

```ruby
class DefaultState < State
  def do_plus
    [self, AddOpToken.instance]
  end
end
```

#### Tokens

I have already provided implementations of the tokens the lexer will need to
generate.  For numeric literals, you can use one of:

```ruby
IntegerToken.new('42')
DecimalToken.new('42.0')
```

Operator tokens are implemented using the [singleton design
pattern][singleton].  As such, instead of instantiating new instances of each
token using `new`, you can instead use `instance`, as in:

```ruby
AddOpToken.instance
SubtractOpToken.instance
LeftParenthesisToken.instance
```

[singleton]: https://en.wikipedia.org/wiki/Singleton_pattern
[state]: https://en.wikipedia.org/wiki/State_pattern

#### Testing your code

To help guide you through the implementation process, I have included a unit
test suite for the lexer in `test/calculator/lexer_test.rb`.  Most of the
methods are disabled by having the `DISABLED_` prefix.  You can enable each
test by removing that prefix so that the test name will have the form
`test_XXX`.  You can than run `rake` or `rake test` to see the results.  If you
are using an IDE like RubyMine, it may be configured to run the tests
automatically.

### Generating an LL grammar

The following grammar describes the simple mathematical expression language from your last homework:

* *expression* -> { *expression* ( AddOpToken | SubtractOpToken ) } *term*
* *term* -> { *term* ( MultiplyOpToken | DivideOpToken ) } *factor*
* *factor* -> *base* { ExponentOpToken *factor* }
* *base* -> IntegerToken | DecimalToken | LeftParenthesisToken *expression* RightParenthesisToken

The above grammar is left-recursive (in particular, the *expression* and *term*
rules are left-recursive).  This means it is not an LL grammar and cannot be
parsed by an LL parser such as the recursive descent parser you will write.

Use left-factorisation to convert the above into an LL grammar. You should
document the LL grammar you have generated in the documentation for the Parser
class in `lib/calculator/Parser.rb`.

### Creating a recursive descent parser

Now that you have created an LL grammar, you can now implement a recursive
descent parser for that grammar.

#### Syntax tree nodes

For your convenience, I have provided the classes for the syntax tree nodes
your parser should generate.  The leaves for each node should either a be the
input token or be empty (an epsilon node).  For example:

```ruby
# a base node containing an integer
BaseNode.new(IntegerToken.new(42))

# an empty expression′ node
ExpressionPrimeNode.new
```

#### Implementing the parser

I have provided an entry point for you, `parse_expression`.  You will need to
create more `parse_XXX` methods for each type of non-terminal in your grammar.
The tokens that have been passed to the parser are found in `@tokens`.  You can
see what the next token is by calling `@tokens.first`.  To move to the next
token, you can use the convenience method `shift_tokens` that returns the first
token while moving to the next token.

I recommend that you implement each of these methods by having them return the
tree each has constructed.  For example, the following snippet will check to
see if the next node is an integer.  If so, it returns it wrapped in
a BaseNode.  Otherwise, it raises a SyntaxError.

```ruby
def parse_base
  case @tokens.next
    when IntegerToken
      BaseNode.new(shift_tokens)
    else
      raise SyntaxError(‘Integer expected’)
  end
end
```

#### Testing

Again, like last time, you can test your parser using the test suite in
`test/calculator/parser_test.rb`.
