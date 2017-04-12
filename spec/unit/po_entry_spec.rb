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
end
