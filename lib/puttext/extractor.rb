require_relative 'parser/ruby'
require_relative 'po_file'

module PutText
  class Extractor
    PARSERS = {
      ruby: PutText::Parser::Ruby.new
    }.freeze

    EXTENSIONS = {
      '.rb' => :ruby
    }.freeze

    # Thrown when a given file cannot be parsed, because its format or language
    # is not supported.
    class UnsupportedFileError < StandardError; end

    # Thrown when the path passed to #extract does not exist.
    class NoSuchFileError < StandardError; end

    # Check if a file is supported by the parser, based on its extension.
    # @return [Boolean] whether the file is supported.
    def self.is_file_supported?(path)
      EXTENSIONS.keys.any? { |ext| path.end_with?(ext) }
    end

    # Extract strings from files in the given path.
    # @param [String] path the path of a directory or file to extract strings
    #   from.
    # @return [POFile] a POFile object, representing the strings extracted from
    #   the files or file in the specified path.
    def extract(path)
      files           = files_in_path(path)
      supported_files = filter_files(files, path)

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
      EXTENSIONS.each do |ext, lang|
        return PARSERS[lang] if path.end_with?(ext)
      end

      raise UnsupportedFileError, 'file not supported: %{path}' % { path: path }
    end

    def parse_files(files)
      entries = []

      files.each do |path|
        entries += extract_from_file(path)
      end

      POFile.new(entries)
    end

    def filter_files(files, path)
      supported_files = files.select do |file|
        self.class.is_file_supported?(file)
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
        raise NoSuchFileError,
          'no such file or directory: %{path}' % { path: path }
      end

      files
    end
  end
end