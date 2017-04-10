require_relative 'language_parsers/ruby'

require 'fast_gettext'

module RXGetText
  class Parser
    include FastGettext::Translation

    # Initialize individual language parsers
    @extension_map = {}

    LANGUAGE_PARSERS = [
      RXGetText::LanguageParsers::Ruby
    ].freeze

    LANGUAGE_PARSERS.each do |parser_class|
      parser_obj = parser_class.new

      parser_class.get_extensions.each do |ext|
        @extension_map[ext] = parser_obj
      end
    end

    # Check if a file is supported by the parser, based on its extension.
    # @return [Boolean] whether the file is supported.
    def self.is_file_supported?(path)
      @extension_map.keys.any? { |ext| path.end_with?(ext) }
    end

    def self._extension_map
      @extension_map
    end

    # Parse gettext strings from a file in the path.
    # @param [String] the path of the file to parse.
    # @return [Array<RXGetText::POEntry>] an array of POEntry objects extracted
    #   from the given file.
    def strings_from_file(path)
      parser_by_path(path).strings_from_file(path)
    end

    private

    def parser_by_path(path)
      self.class._extension_map.each do |ext, parser|
        return parser if path.end_with?(ext)
      end

      raise _('file not supported: %{path}') % { path: path }
    end
  end
end
