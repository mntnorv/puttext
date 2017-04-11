require_relative 'parser'

require 'fast_gettext'

module RXGetText
  class Runner
    include FastGettext::Translation

    def self.run_cmd(args)
      new.run_cmd(args)
    end

    def initialize; end

    def run_cmd(args)
      options = parse_args(args)
      run(options[:path])
    rescue => e
      puts "#{_('error:')} #{e.message}"
      puts e.backtrace
      exit 1
    end

    def run(path)
      files           = files_in_path(path)
      supported_files = filter_files(files, path)

      parser = RXGetText::Parser.new

      parse_files(parser, supported_files)
    end

    private

    def parse_files(parser, files)
      strings = []

      files.each do |path|
        strings += parser.strings_from_file(path)
      end

      puts strings.map(&:to_s).join
      strings
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
      if args.length != 1
        print_usage
        exit 1
      else
        {
          path: args[0]
        }
      end
    end

    def print_usage
      puts _('Usage: rxgettext [PATH]')
    end
  end
end
