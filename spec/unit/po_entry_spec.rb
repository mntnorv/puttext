require 'spec_helper'

describe RXGetText::POEntry do
  describe '#initialize' do
    context 'creating a simple PO entry' do
      let(:entry) { described_class.new(msgid: 'An error occurred!') }

      it 'sets the passed msgid attribute' do
        expect(entry.msgid).to eq('An error occurred!')
      end

      it 'sets msgid_plural to nil' do
        expect(entry.msgid_plural).to be nil
      end

      it 'sets msgctxt to nil' do
        expect(entry.msgctxt).to be nil
      end

      it 'sets references to an empty array' do
        expect(entry.references).to eq([])
      end
    end

    context 'creating a pluralized entry' do
      let(:entry) do
        described_class.new(
          msgid: 'An error occurred!',
          msgid_plural: '%d errors occurred!'
        )
      end

      it 'sets the passed msgid attribute' do
        expect(entry.msgid).to eq('An error occurred!')
      end

      it 'sets the passed msgid_plural attribute' do
        expect(entry.msgid_plural).to eq('%d errors occurred!')
      end
    end

    context 'creating an entry with a context' do
      let(:entry) do
        described_class.new(
          msgid: 'An error occurred!',
          msgctxt: 'Error modal'
        )
      end

      it 'sets the passed msgid attribute' do
        expect(entry.msgid).to eq('An error occurred!')
      end

      it 'sets the passed msgctxt attribute' do
        expect(entry.msgctxt).to eq('Error modal')
      end
    end

    context 'creating an entry with references' do
      let(:entry) do
        described_class.new(
          msgid: 'An error occurred!',
          references: ['errors.rb:15']
        )
      end

      it 'sets the passed msgid attribute' do
        expect(entry.msgid).to eq('An error occurred!')
      end

      it 'sets the passed msgctxt attribute' do
        expect(entry.references).to eq(['errors.rb:15'])
      end
    end

    context 'creating an entry with a context in msgid' do
      context 'context is separated by the default separator' do
        let(:entry) do
          described_class.new(
            msgid: 'Error modal|An error occurred!'
          )
        end

        it 'sets the correct separated msgid' do
          expect(entry.msgid).to eq('An error occurred!')
        end

        it 'sets the passed msgctxt attribute' do
          expect(entry.msgctxt).to eq('Error modal')
        end
      end

      context 'context is separated by a custom separator' do
        let(:entry) do
          described_class.new(
            msgid: 'Error modal;;An error occurred!',
            separator: ';;'
          )
        end

        it 'sets the correct separated msgid' do
          expect(entry.msgid).to eq('An error occurred!')
        end

        it 'sets the passed msgctxt attribute' do
          expect(entry.msgctxt).to eq('Error modal')
        end
      end
    end
  end

  describe '#references?' do
    context 'entry has references' do
      let(:entry) do
        described_class.new(
          msgid: 'An error occurred!',
          references: ['errors.rb:15']
        )
      end

      it 'returns true' do
        expect(entry.references?).to be true
      end
    end

    context 'entry does not have references' do
      let(:entry) { described_class.new(msgid: 'An error occurred!') }

      it 'returns false' do
        expect(entry.references?).to be false
      end
    end
  end

  describe '#plural?' do
    context 'entry is a pluralized entry' do
      let(:entry) do
        described_class.new(
          msgid: 'An error occurred!',
          msgid_plural: '%d errors occurred!'
        )
      end

      it 'returns true' do
        expect(entry.plural?).to be true
      end
    end

    context 'entry is not pluralized entry' do
      let(:entry) { described_class.new(msgid: 'An error occurred!') }

      it 'returns false' do
        expect(entry.plural?).to be false
      end
    end
  end

  describe '#merge' do
    let(:entry) do
      described_class.new(
        msgid: 'An error occurred!',
        references: ['errors.rb:15']
      )
    end

    let(:other_entry) do
      described_class.new(
        msgid: 'An error occurred!',
        references: [
          'subfolder/random_file.rb:5',
          'subfolder/another_file.rb:168'
        ]
      )
    end

    let(:merged_entry) { entry.merge(other_entry) }

    it 'merges references of both entries' do
      expect(merged_entry.references).to eq([
        'errors.rb:15',
        'subfolder/random_file.rb:5',
        'subfolder/another_file.rb:168'
      ])
    end
  end

  describe '#unique_key' do
    let(:entry_1) { described_class.new(msgid: 'An error occurred!') }
    let(:entry_2) { described_class.new(msgid: 'Another message') }

    let(:ctxt_entry_1) do
      described_class.new(
        msgid: 'An error occurred!',
        msgctxt: 'Error modal'
      )
    end

    let(:ctxt_entry_2) do
      described_class.new(
        msgid: 'An error occurred!',
        msgctxt: 'Error modal'
      )
    end

    context 'comparing the key from the same entry' do
      it 'returns the same key' do
        expect(entry_1.unique_key).to eq(entry_1.unique_key)
      end
    end

    context 'comparing keys of entries with the same message and context' do
      it 'returns the same key' do
        expect(ctxt_entry_1.unique_key).to eq(ctxt_entry_2.unique_key)
      end
    end

    context 'comparing keys of entries with different messages' do
      it 'returns different keys' do
        expect(entry_1.unique_key).not_to eq(entry_2.unique_key)
      end
    end

    context 'comparing keys of entries with the same message but different contexts' do
      it 'returns different keys' do
        expect(entry_1.unique_key).not_to eq(ctxt_entry_1.unique_key)
      end
    end
  end
end
