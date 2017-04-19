# frozen_string_literal: true

require 'spec_helper'
require 'unindent'

describe PutText::Extractor do
  describe '.file_supported?(path)' do
    context 'passing a file with a supported extension' do
      it 'returns true' do
        expect(described_class.file_supported?('test/file.rb')).to be true
      end
    end

    context 'passing a file with an unsupported extension' do
      it 'returns false' do
        expect(described_class.file_supported?('test/file.php')).to be false
      end
    end
  end

  describe '#extract_from_file' do
    context 'passing a Ruby file' do
      before do
        allow_any_instance_of(PutText::Parser::Ruby).to(
          receive(:strings_from_file).and_return(['stuff'])
        )
      end

      it 'uses the Ruby parser to extract strings' do
        expect_any_instance_of(PutText::Parser::Ruby).to(
          receive(:strings_from_file).with('test/file.rb')
        )

        subject.extract_from_file('test/file.rb')
      end

      it 'returns the results of the #strings_from_file call' do
        expect(subject.extract_from_file('test/file.rb')).to eq(['stuff'])
      end
    end

    context 'passing a Slim file' do
      before do
        allow_any_instance_of(PutText::Parser::Slim).to(
          receive(:strings_from_file).and_return(['stuff'])
        )
      end

      it 'uses the Slim parser to extract strings' do
        expect_any_instance_of(PutText::Parser::Slim).to(
          receive(:strings_from_file).with('test/file.slim')
        )

        subject.extract_from_file('test/file.slim')
      end

      it 'returns the results of the #strings_from_file call' do
        expect(subject.extract_from_file('test/file.slim')).to eq(['stuff'])
      end
    end

    context 'passing an unsupported file' do
      it 'throws a PutText::Extractor::UnsupportedFileError' do
        expect { subject.extract_from_file('test/file.php') }.to raise_error(
          PutText::Extractor::UnsupportedFileError
        )
      end
    end
  end

  describe '#extract' do
    let(:entry) { PutText::POEntry.new(msgid: 'test') }

    context 'passing a folder as the path' do
      let(:fixtures_path) do
        File.join(File.dirname(__FILE__), '../fixtures/extractor_fixtures')
      end

      context 'files do not contain any strings' do
        before do
          allow(subject).to receive(:extract_from_file).and_return([])
          subject.extract(fixtures_path)
        end

        it 'extracts strings from 4 files' do
          expect(subject).to have_received(:extract_from_file).exactly(4).times
        end

        it 'extracts strings from file_1.rb' do
          expect(subject).to have_received(:extract_from_file).with(
            %r{extractor_fixtures/file_1\.rb$}
          )
        end

        it 'extracts strings from file_2.rb' do
          expect(subject).to have_received(:extract_from_file).with(
            %r{extractor_fixtures/file_2\.rb$}
          )
        end

        it 'extracts strings from subfolder/subfile_1.rb' do
          expect(subject).to have_received(:extract_from_file).with(
            %r{extractor_fixtures/subfolder/subfile_1\.rb$}
          )
        end

        it 'extracts strings from subfolder/subfile_2.rb' do
          expect(subject).to have_received(:extract_from_file).with(
            %r{extractor_fixtures/subfolder/subfile_2\.rb$}
          )
        end
      end

      context 'files contain some strings' do
        before do
          allow(subject).to receive(:extract_from_file).and_return([entry])
        end

        it 'returns a POFile with entries extracted from the files' do
          dup_entry = entry.dup

          expect(subject.extract(fixtures_path)).to eq(
            PutText::POFile.new([dup_entry, dup_entry, dup_entry, dup_entry])
          )
        end
      end
    end

    context 'passing a folder as the path' do
      let(:fixture_path) do
        File.join(
          File.dirname(__FILE__),
          '../fixtures/extractor_fixtures/file_1.rb'
        )
      end

      before do
        allow(subject).to receive(:extract_from_file).and_return([entry])
      end

      it 'extracts strings from 1 file' do
        subject.extract(fixture_path)
        expect(subject).to have_received(:extract_from_file).once
      end

      it 'extracts contents from file_1.rb' do
        subject.extract(fixture_path)
        expect(subject).to have_received(:extract_from_file).with(
          %r{extractor_fixtures/file_1\.rb$}
        )
      end

      it 'returns a POFile with entries extracted from the file' do
        expect(subject.extract(fixture_path)).to eq(
          PutText::POFile.new([entry])
        )
      end
    end

    context 'passing a not existing path' do
      it 'throws a PutText::Extractor::NoSuchFileError' do
        expect { subject.extract('non/existing/path') }.to raise_error(
          PutText::Extractor::NoSuchFileError
        )
      end
    end
  end
end
