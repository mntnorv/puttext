# frozen_string_literal: true

require 'spec_helper'
require 'unindent'

describe PutText::Parser::Ruby do
  it_behaves_like 'PutText::Parser::Base'

  describe '#strings_from_source' do
    context 'passing Ruby code with gettext usages' do
      let(:ruby_code) do
        <<-RUBY.unindent
          class RandomClass
            def array_of_text
              [
                gettext('gettext'),
                _('underscore'),
                ngettext('1 ngettext', '%d ngettexts', 5),
                n_('1 underscore', '%d underscores', 5),
                sgettext('context|sgettext'),
                s_('context---s underscore', '---'),
                nsgettext('context|1 nsgettext', '%d nsgettexts', 5),
                ns_('context---1 ns underscore', '%d ns underscores', 5, '---'),
                pgettext('context', 'pgettext'),
                p_('context', 'p underscore'),
                npgettext('context', '1 npgettext', '%d npgettexts', 5),
                np_('context', '1 np underscore', '%d np underscores', 5)
              ]
            end

            def method_with_underscore_param(_)
              'something'
            end

            before_event -> (_) { 'do_important_stuff' }
          end
        RUBY
      end

      before do
        allow(PutText::POEntry).to receive(:new)
        subject.strings_from_source(
          ruby_code, filename: 'test.rb', first_line: 8
        )
      end

      it 'extracts the correct number of strings' do
        expect(PutText::POEntry).to have_received(:new).exactly(12).times
      end

      it 'correctly extracts string from gettext calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgid: 'gettext',
          references: ['test.rb:11']
        )
      end

      it 'correctly extracts string from _ calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgid: 'underscore',
          references: ['test.rb:12']
        )
      end

      it 'correctly extracts string from ngettext calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgid: '1 ngettext',
          msgid_plural: '%d ngettexts',
          references: ['test.rb:13']
        )
      end

      it 'correctly extracts string from n_ calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgid: '1 underscore',
          msgid_plural: '%d underscores',
          references: ['test.rb:14']
        )
      end

      it 'correctly extracts string from sgettext calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgid: 'context|sgettext',
          references: ['test.rb:15']
        )
      end

      it 'correctly extracts string from s_ calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgid: 'context---s underscore',
          separator: '---',
          references: ['test.rb:16']
        )
      end

      it 'correctly extracts string from nsgettext calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgid: 'context|1 nsgettext',
          msgid_plural: '%d nsgettexts',
          references: ['test.rb:17']
        )
      end

      it 'correctly extracts string from ns_ calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgid: 'context---1 ns underscore',
          msgid_plural: '%d ns underscores',
          separator: '---',
          references: ['test.rb:18']
        )
      end

      it 'correctly extracts string from pgettext calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgctxt: 'context',
          msgid: 'pgettext',
          references: ['test.rb:19']
        )
      end

      it 'correctly extracts string from p_ calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgctxt: 'context',
          msgid: 'p underscore',
          references: ['test.rb:20']
        )
      end

      it 'correctly extracts string from npgettext calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgctxt: 'context',
          msgid: '1 npgettext',
          msgid_plural: '%d npgettexts',
          references: ['test.rb:21']
        )
      end

      it 'correctly extracts string from np_ calls' do
        expect(PutText::POEntry).to have_received(:new).with(
          msgctxt: 'context',
          msgid: '1 np underscore',
          msgid_plural: '%d np underscores',
          references: ['test.rb:22']
        )
      end
    end

    context 'passing an empty string' do
      it 'returns an empty array' do
        expect(subject.strings_from_source('')).to eq([])
      end
    end

    context 'passing Ruby code that uses text interpolations' do
      let(:ruby_code) do
        <<-RUBY.unindent
          class RandomClass
            def interpolations
              'stuff'
            end

            def do_something
              _("something with \#{interpolations}")
            end
          end
        RUBY
      end

      it 'throws a PutText::Parser::ParseError error' do
        expect { subject.strings_from_source(ruby_code) }.to raise_error(
          PutText::Parser::ParseError
        )
      end
    end
  end
end
