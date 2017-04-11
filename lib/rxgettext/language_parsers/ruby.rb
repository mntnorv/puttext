require_relative 'base'
require_relative '../po_entry'

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

    def strings_from_source(source, filename: '(string)', first_line: 1)
      buffer = Parser::Source::Buffer.new(filename, first_line)
      buffer.source = source

      @ruby_parser.reset
      ast = @ruby_parser.parse(buffer)

      find_strings_in_ast(ast)
    end

    private

    def string_from_ast_node(ast_node)
      case ast_node.type
      when :str
        filename = ast_node.location.expression.source_buffer.name
        line     = ast_node.location.line

        RXGetText::POEntry.new(
          msgid: ast_node.children[0],
          references: ["#{filename}:#{line}"]
        )
      else
        raise _("unsupported AST node type: %{type}") % { type: ast_node.type }
      end
    end

    def find_strings_in_ast(ast_node)
      strings = []

      if ast_node.type == :send
        case ast_node.children[1]
        when :_
          strings << string_from_ast_node(ast_node.children[2])
        end
      end

      ast_node.children.each do |child|
        next unless child.is_a? Parser::AST::Node
        strings += find_strings_in_ast(child)
      end

      strings
    end
  end
end
