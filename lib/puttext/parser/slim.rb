# frozen_string_literal: true

require_relative 'base'
require_relative 'ruby'

# rubocop:disable Lint/HandleExceptions
begin
  require 'slim'
rescue LoadError
  # Optional dependency, do not fail if not found
end
# rubocop:enable Lint/HandleExceptions

module PutText
  module Parser
    class Slim < Base
      # Checks if this parser is supported.
      # @return [Boolean] false when the slim gem is not loaded, true otherwise.
      def self.supported?
        defined? ::Slim
      end

      def initialize
        @ruby_parser = PutText::Parser::Ruby.new
        @slim_engine = ::Slim::Engine.new(enable_engines: [])
      end

      def strings_from_source(source, filename: '(string)', first_line: 1)
        slim_ruby_code = @slim_engine.call(source)

        @ruby_parser.strings_from_source(
          slim_ruby_code,
          filename: filename,
          first_line: first_line
        )
      end
    end
  end
end
