# frozen_string_literal: true

require_relative 'base'
require_relative 'ruby'

begin
  require 'slim'

  module PutText
    module Parser
      class Slim < Base
        def initialize
          @ruby_parser = PutText::Parser::Ruby.new
          @slim_engine = Engine.new
        end

        def strings_from_source(source, filename: '(string)', first_line: 1)
          slim_ruby_code = @slim_engine.call(source)

          @ruby_parser.strings_from_source(
            slim_ruby_code,
            filename: filename,
            first_line: first_line
          )
        end

        class IgnoreEmbedded < ::Slim::Filter
          def on_slim_embedded(_name, body)
            newlines = count_newlines(body)

            node = [:multi]
            newlines.times { node.push [:newline] }
            node
          end

          private

          def count_newlines(body)
            newlines = 0
            newlines += 1 if body.first == :newline

            body.each do |el|
              newlines += count_newlines(el) if el.is_a?(Array)
            end

            newlines
          end
        end

        class Engine < ::Slim::Engine
          replace ::Slim::Embedded, IgnoreEmbedded
        end
      end
    end
  end

# rubocop:disable Lint/HandleExceptions
rescue LoadError
  # Optional dependency, do not fail if not found
end
# rubocop:enable Lint/HandleExceptions
