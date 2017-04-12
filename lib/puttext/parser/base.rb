# frozen_string_literal: true

require_relative '../po_entry'

module PutText
  module Parser
    class Base
      # Thrown when any error parsing a file occurs
      class ParseError < StandardError; end

      # Parse gettext strings from a file in the path.
      # @param [String] path the path of the file to parse.
      # @return [Array<POEntry>] an array of POEntry objects extracted
      #   from the given file.
      def strings_from_file(path)
        strings_from_source(File.read(path), filename: path)
      end

      # @abstract Subclass is expected to implement #strings_from_source
      # @!method strings_from_source(source, opts)
      #   Parse gettext strings from a given snippet of source code.
      #   @param [String] source the snippet of source code to parse.
      #   @param [Hash] opts
      #   @option opts [String] :filename path of the file being parsed.
      #     Defaults to "(string)".
      #   @option opts [Integer] :first_line number of the first line being
      #     parsed. Defaults to 1.
      #   @return [Array<POEntry>] an array of POEntry objects
      #     extracted from the given source code.
    end
  end
end
