require_relative '../po_entry'

module RXGetText::Parser
  class Base
    class ParseError < StandardError; end

    # Set the supported file extensions by this parser.
    # @param [Array<String>] array the array of supported file extensions.
    def self.extensions(array)
      @file_extensions = array
    end

    # Get the supported file extensions by this parser.
    # @return [Array<String>] the array of supported file extensions.
    def self.get_extensions
      @file_extensions || []
    end

    # Parse gettext strings from a file in the path.
    # @param [String] the path of the file to parse.
    # @return [Array<RXGetText::POEntry>] an array of POEntry objects extracted
    #   from the given file.
    def strings_from_file(path)
      strings_from_source(File.read(path), filename: path)
    end

    # @abstract Subclass is expected to implement #strings_from_source
    # @!method strings_from_source(source)
    #   Parse gettext strings from a given snippet of source code.
    #   @param [String] the snippet of source code to parse.
    #   @option opts [String] :filename path of the file being parsed. Defaults
    #     to "(string)".
    #   @option opts [Integer] :first_line number of the first line being
    #     parsed. Defaults to 1.
    #   @return [Array<RXGetText::POEntry>] an array of POEntry objects
    #     extracted from the given source code.
  end
end
