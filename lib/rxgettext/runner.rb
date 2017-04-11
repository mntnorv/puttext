require_relative 'parser'
require_relative 'po_file'

require 'fast_gettext'
require 'optparse'

module RXGetText
  class Runner
    include FastGettext::Translation

    USAGE_TEXT = 'Usage: rxgettext LOCATION [options]'

    def self.run_cmd(args)
      new.run_cmd(args)
    end

    def initialize; end

    def run_cmd(args)
      options = parse_args(args)
      output = STDOUT

      if options[:output_file]
        output = File.open(options[:output_file], 'w')
      end

      run(options[:path], output)

      output.close if options[:output_file]
    rescue => e
      puts "#{_('error:')} #{e.message}"
      puts e.backtrace
      exit 1
    end

    def run(path, output)
      files           = files_in_path(path)
      supported_files = filter_files(files, path)

      parser  = RXGetText::Parser.new
      po_file = parse_files(parser, supported_files)

      po_file.write_to(output)
    end

    private

    def parse_files(parser, files)
      entries = []

      files.each do |path|
        entries += parser.strings_from_file(path)
      end

      POFile.new(entries)
    end

    def filter_files(files, path)
      supported_files = files.select { |file| Parser.is_file_supported?(file) }

      if supported_files.length == 0
        raise _('no supported files found: %{path}') % { path: path }
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
        raise _('no such file or directory: %{path}') % { path: path }
      end

      files
    end

    def parse_args(args)
      options = {}

      args_left = OptionParser.new do |opts|
        opts.banner = USAGE_TEXT

        opts.on('-o', '--output PATH', 'Output file path') do |o|
          options[:output_file] = o
        end
      end.parse!(args)

      if args_left.length != 1
        print_usage
        exit 1
      else
        options[:path] = args_left[0]
        options
      end
    end

    def print_usage
      puts USAGE_TEXT
    end
  end
end
