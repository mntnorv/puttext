require_relative 'base'

require 'parser/current'

# opt-in to most recent Parser AST format:
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

module RXGetText::LanguageParsers
  class Ruby < Base
    extensions %w(.rb)

    def initialize
      @ruby_parser = Parser::CurrentRuby.new
    end

    def strings_from_source(source)
      buffer = Parser::Source::Buffer.new('(string)')
      buffer.source = source

      @ruby_parser.reset
      ast = @ruby_parser.parse(buffer)

      strings = []
      find_strings_in_ast(strings, ast)
      strings
    end

    private

    def add_string_from_ast_node(array, ast_node)
      case ast_node.type
      when :str
        array << ast_node.children[0]
      else
        raise _("unsupported AST node type: %{type}") % { type: ast_node.type }
      end
    end

    def find_strings_in_ast(array, ast_node)
      if ast_node.type == :send
        case ast_node.children[1]
        when :_
          add_string_from_ast_node(array, ast_node.children[2])
        end
      end

      ast_node.children.each do |child|
        next unless child.is_a? Parser::AST::Node
        find_strings_in_ast(array, child)
      end
    end
  end
end
