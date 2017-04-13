# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'puttext'

# Load shared specs.
Dir[File.join(File.dirname(__FILE__), 'shared/**/*.rb')].each { |f| require f }
