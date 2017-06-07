# frozen_string_literal: true

require_relative 'base'
require_relative '../po_entry'

require 'parser/current'

# opt-in to most recent Parser AST format:
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

module PutText
  module Parser
    class Ruby < Base
      METHODS = {
        gettext:   :regular,
        _:         :regular,
        N_:        :regular,
        ngettext:  :plural,
        n_:        :plural,
        Nn_:       :plural,
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
      }.freeze

      def initialize
        @ruby_parser = ::Parser::CurrentRuby.new
      end

      def strings_from_source(source, filename: '(string)', first_line: 1)
        buffer = ::Parser::Source::Buffer.new(filename, first_line)
        buffer.source = source

        @ruby_parser.reset
        ast = @ruby_parser.parse(buffer)

        if ast.is_a? ::Parser::AST::Node
          find_strings_in_ast(ast)
        else
          []
        end
      end

      private

      def string_from_ast_node(ast_node)
        return if ast_node.nil?

        case ast_node.type
        when :str
          ast_node.children[0]
        else
          raise ParseError,
                format('unsupported AST node type: %s', ast_node.type)
        end
      end

      def po_entry_from_ast_node(ast_node, type)
        filename = ast_node.location.expression.source_buffer.name
        line     = ast_node.location.line

        entry_attrs = { references: ["#{filename}:#{line}"] }

        PARAMS[type].each_with_index do |name, index|
          next if name == :_ # skip parameters named _

          param = string_from_ast_node(ast_node.children[index + 2])
          entry_attrs[name] = param if param
        end

        PutText::POEntry.new(entry_attrs)
      end

      def find_strings_in_ast(ast_node)
        entries = []

        if ast_node.type == :send && METHODS[ast_node.children[1]]
          entries << po_entry_from_ast_node(
            ast_node,
            METHODS[ast_node.children[1]]
          )
        else
          entries += find_strings_in_each_ast(ast_node.children)
        end

        entries
      end

      def find_strings_in_each_ast(ast_nodes)
        entries = []

        ast_nodes.each do |node|
          next unless node.is_a? ::Parser::AST::Node
          entries += find_strings_in_ast(node)
        end

        entries
      end
    end
  end
end
