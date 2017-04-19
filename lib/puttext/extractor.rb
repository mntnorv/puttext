# frozen_string_literal: true

require_relative 'parser/ruby'
require_relative 'parser/slim'
require_relative 'po_file'

module PutText
  class Extractor
    PARSERS = {
      ruby: PutText::Parser::Ruby,
      slim: PutText::Parser::Slim
    }.freeze

    EXTENSIONS = {
      '.rb'   => :ruby,
      '.slim' => :slim
    }.freeze

    # Filter out supported parsers
    SUPPORTED_PARSERS = {}.freeze
    PARSERS.each do |name, parser_class|
      next unless parser_class.supported?
      SUPPORTED_PARSERS[name] = parser_class.new
    end

    # Filter out supported file extensions
    SUPPORTED_EXTENSIONS = {}.freeze
    EXTENSIONS.each do |ext, parser|
      next unless SUPPORTED_PARSERS[parser]
      SUPPORTED_EXTENSIONS[ext] = parser
    end

    # Thrown when a given file cannot be parsed, because its format or language
    # is not supported.
    class UnsupportedFileError < StandardError; end

    # Thrown when the path passed to #extract does not exist.
    class NoSuchFileError < StandardError; end

    # Check if a file is supported by the parser, based on its extension.
    # @return [Boolean] whether the file is supported.
    def self.file_supported?(path)
      SUPPORTED_EXTENSIONS.keys.any? { |ext| path.end_with?(ext) }
    end

    # Extract strings from files in the given path.
    # @param [String] path the path of a directory or file to extract strings
    #   from.
    # @return [POFile] a POFile object, representing the strings extracted from
    #   the files or file in the specified path.
    def extract(path)
      files           = files_in_path(path)
      supported_files = filter_files(files)

      parse_files(supported_files)
    end

    # Parse gettext strings from a file in the path.
    # @param [String] path the path of the file to parse.
    # @return [Array<POEntry>] an array of POEntry objects extracted
    #   from the given file.
    def extract_from_file(path)
      parser_by_path(path).strings_from_file(path)
    end

    private

    def parser_by_path(path)
      SUPPORTED_EXTENSIONS.each do |ext, lang|
        return SUPPORTED_PARSERS[lang] if path.end_with?(ext)
      end

      raise UnsupportedFileError, format('file not supported: %s', path)
    end

    def parse_files(files)
      entries = []

      files.each do |path|
        entries += extract_from_file(path)
      end

      POFile.new(entries)
    end

    def filter_files(files)
      supported_files = files.select do |file|
        self.class.file_supported?(file)
      end

      supported_files
    end

    def files_in_path(path)
      files = []

      if File.file?(path)
        files = [path]
      elsif File.directory?(path)
        files = Dir.glob(File.join(path, '**/*'))
      else
        raise NoSuchFileError, format('no such file or directory: %s', path)
      end

      files
    end
  end
end
