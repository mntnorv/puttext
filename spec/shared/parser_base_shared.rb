# frozen_string_literal: true

require 'unindent'

RSpec.shared_examples 'PutText::Parser::Base' do
  describe '#strings_from_file' do
    let(:fixture_file_path) do
      File.join(
        File.dirname(__FILE__),
        '../fixtures/parser_base_shared_fixture.rb'
      )
    end

    let(:fixture_file_contents) do
      <<-RUBY.unindent
        class TestClass
          _('string')
        end
      RUBY
    end

    before do
      allow(subject).to receive(:strings_from_source).and_return(['something'])
    end

    it 'passes file content to strings_from_source' do
      subject.strings_from_file(fixture_file_path)

      expect(subject).to have_received(:strings_from_source).with(
        fixture_file_contents, filename: fixture_file_path
      )
    end

    it 'returns the result from strings_from_source' do
      expect(subject.strings_from_file(fixture_file_path)).to eq(['something'])
    end
  end
end
