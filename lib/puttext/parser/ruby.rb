require_relative 'base'
require_relative '../po_entry'

require 'parser/current'

# opt-in to most recent Parser AST format:
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

module PutText::Parser
  class Ruby < Base
    extensions %w(.rb)

    METHODS = {
      gettext:   :regular,
      _:         :regular,
      ngettext:  :plural,
      n_:        :plural,
      sgettext:  :context_sep,
      s_:        :context_sep,
      nsgettext: :context_sep_plural,
      ns_:       :context_sep_plural,
      pgettext:  :context,
      p_:        :context,
      npgettext: :context_plural,
      np_:       :context_plural
    }.freeze

    PARAMS = {
      regular:            %i(msgid),
      plural:             %i(msgid msgid_plural),
      context:            %i(msgctxt msgid),
      context_plural:     %i(msgctxt msgid msgid_plural),
      context_sep:        %i(msgid separator),
      context_sep_plural: %i(msgid msgid_plural _ separator)
    }

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
      return if ast_node.nil?

      case ast_node.type
      when :str
        ast_node.children[0]
      else
        raise ParseError,
          'unsupported AST node type: %{type}' % { type: ast_node.type }
      end
    end

    def po_entry_from_ast_node(ast_node, type)
      filename = ast_node.location.expression.source_buffer.name
      line     = ast_node.location.line

      entry_attrs = {
        references: ["#{filename}:#{line}"]
      }

      PARAMS[type].each_with_index do |name, index|
        next if name == :_ # skip parameters named _

        param = string_from_ast_node(ast_node.children[index + 2])
        entry_attrs[name] = param
      end

      PutText::POEntry.new(entry_attrs)
    end

    def find_strings_in_ast(ast_node)
      return [] unless ast_node.is_a? Parser::AST::Node

      entries = []

      if ast_node.type == :send && METHODS[ast_node.children[1]]
        entries << po_entry_from_ast_node(
          ast_node,
          METHODS[ast_node.children[1]]
        )
      end

      ast_node.children.each do |child|
        next unless child.is_a? Parser::AST::Node
        entries += find_strings_in_ast(child)
      end

      entries
    end
  end
end
