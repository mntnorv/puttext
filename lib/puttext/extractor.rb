# frozen_string_literal: true

require_relative 'parser/ruby'
require_relative 'parser/slim'
require_relative 'po_file'

module PutText
  class Extractor
    EXTENSIONS = {
      '.rb'   => 'Ruby',
      '.slim' => 'Slim'
    }.freeze

    # Thrown when a given file cannot be parsed, because its format or language
    # is not supported.
    class UnsupportedFileError < StandardError; end

    # Thrown when the path passed to #extract does not exist.
    class NoSuchFileError < StandardError; end

    # Return the class of a parser by its name
    # @param [String] name the name of the parser.
    # @return [Class] the classof the parser
    def self.parser_class_by_name(name)
      PutText::Parser.const_get(name)
    end

    # Check if a file is supported by the parser, based on its extension.
    # @return [Boolean] whether the file is supported.
    def self.file_supported?(path)
      EXTENSIONS.each do |ext, parser_name|
        next unless path.end_with?(ext)
        next unless parser_class_by_name(parser_name)
        return true
      end

      false
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

    def parser_by_name(name)
      return @parsers[name] if @parsers && @parsers[name]

      @parsers ||= {}
      parser_class = self.class.parser_class_by_name(name)
      return unless parser_class

      parser = parser_class.new
      @parsers[name] = parser
      parser
    end

    def parser_by_path(path)
      EXTENSIONS.each do |ext, name|
        return parser_by_name(name) if path.end_with?(ext)
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
