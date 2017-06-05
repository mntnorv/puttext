# frozen_string_literal: true

require 'spec_helper'
require 'unindent'

describe PutText::POFile do
  describe '#initialize' do
    let(:entry_1) { PutText::POEntry.new(msgid: 'One error occurred') }
    let(:entry_2) { PutText::POEntry.new(msgid: 'Another error occurred') }
    let(:file) { described_class.new([entry_1, entry_2]) }

    it 'creates a POFile with the specified entries' do
      expect(file.entries).to eq([entry_1, entry_2])
    end
  end

  describe '#to_s' do
    let(:entry_1) do
      PutText::POEntry.new(
        msgid: 'Error #1 occurred',
        references: ['error1.rb:1']
      )
    end

    let(:entry_2) do
      PutText::POEntry.new(
        msgid: 'Error #2 occurred',
        references: ['error2.rb:2']
      )
    end

    let(:entry_3) do
      PutText::POEntry.new(
        msgid: 'Error #2 occurred',
        references: ['error2.rb:8']
      )
    end

    before do
      Timecop.freeze(Time.utc(2017))
    end

    after do
      Timecop.return
    end

    let(:file) { described_class.new([entry_1, entry_2, entry_3]) }

    it 'generates correct string' do
      expect(file.to_s).to eq(<<-PO.unindent)
        #, fuzzy
        msgid ""
        msgstr ""
        "POT-Creation-Date: 2017-01-01 00:00+0000\\n"
        "MIME-Version: 1.0\\n"
        "Content-Type: text/plain; charset=UTF-8\\n"

        #: error1.rb:1
        msgid "Error #1 occurred"
        msgstr ""

        #: error2.rb:2 error2.rb:8
        msgid "Error #2 occurred"
        msgstr ""
      PO
    end
  end

  describe '#merge' do
    let(:entry_1) { PutText::POEntry.new(msgid: 'One error occurred') }
    let(:entry_2) { PutText::POEntry.new(msgid: 'Another error occurred') }
    let(:file_1) { described_class.new([entry_1]) }
    let(:file_2) { described_class.new([entry_2]) }

    context 'POFile is passed as an argument' do
      before { file_1.merge(file_2) }

      it 'merges the contents of two POFiles' do
        expect(file_1.entries).to contain_exactly(entry_1, entry_2)
      end
    end

    context 'an object that is not a POFile is passed as an argument' do
      it 'raises an ArgumentError' do
        expect { file_1.merge('string') }.to raise_error(ArgumentError)
      end
    end
  end
end
