require_relative 'extractor'
require 'optparse'

module RXGetText
  class Cmdline
    USAGE_TEXT = 'Usage: rxgettext LOCATION [options]'

    # Run the commmand line tool rxgettext.
    # @param [Array<String>] args the command line arguments.
    def self.run(args)
      new.run(args)
    end

    # Run the commmand line tool rxgettext.
    # @param [Array<String>] args the command line arguments.
    def run(args)
      options = parse_args(args)
      po_file = Extractor.new.extract(options[:path])

      if options[:output_file]
        File.open(options[:output_file], 'w') do |f|
          po_file.write_to(f)
        end
      else
        po_file.write_to(STDOUT)
      end
    rescue => e
      puts "error: #{e.message}"
      puts e.backtrace
      exit 1
    end

    private

    def parse_args(args)
      args_left, options = parse_options(args)

      if args_left.length != 1
        puts USAGE_TEXT
        exit 1
      else
        options[:path] = args_left[0]
        options
      end
    end

    def parse_options(args)
      options = {}

      args_left = OptionParser.new do |opts|
        opts.banner = USAGE_TEXT

        opts.on('-o', '--output PATH', 'Output file path') do |o|
          options[:output_file] = o
        end
      end.parse!(args)

      [args_left, options]
    end
  end
end
