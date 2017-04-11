require_relative 'language_parsers/ruby'

require 'fast_gettext'

module RXGetText
  class Parser
    include FastGettext::Translation

    PARSERS = {
      ruby: RXGetText::LanguageParsers::Ruby.new
    }.freeze

    EXTENSIONS = {
      '.rb' => :ruby
    }.freeze

    # Check if a file is supported by the parser, based on its extension.
    # @return [Boolean] whether the file is supported.
    def self.is_file_supported?(path)
      EXTENSIONS.keys.any? { |ext| path.end_with?(ext) }
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
      EXTENSIONS.each do |ext, lang|
        return PARSERS[lang] if path.end_with?(ext)
      end

      raise _('file not supported: %{path}') % { path: path }
    end
  end
end
