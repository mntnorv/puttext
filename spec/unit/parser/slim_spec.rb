# frozen_string_literal: true

require 'spec_helper'
require 'unindent'

describe PutText::Parser::Slim do
  it_behaves_like 'PutText::Parser::Base'

  describe '#strings_from_source' do
    let(:slim_template) do
      <<-SLIM.unindent
        html attr=code(_('attr')) attr_2="\#{_('attr interpolation')}"
          = multiline_ruby\\
            n_('1 multiline ruby', '%d multiline rubies', 8)

        - if condition
          div *{'hash_attr'=>p_('ctx','splat hash attr')}

        coffee:
          _('should be ignored')

        = method_call do
          html
            | inside
            | with interpolations \#{_('text interpolation')}
          # and_also_ruby
          == _('unescaped string')
      SLIM
    end

    before do
      allow(PutText::POEntry).to receive(:new)
      subject.strings_from_source(
        slim_template, filename: 'test.slim', first_line: 8
      )
    end

    it 'extracts the correct number of strings' do
      expect(PutText::POEntry).to have_received(:new).exactly(6).times
    end

    it 'correctly extracts string from dynamic attribute value' do
      expect(PutText::POEntry).to have_received(:new).with(
        msgid: 'attr',
        references: ['test.slim:8']
      )
    end

    it 'correctly extracts string from interpolated attribute value' do
      expect(PutText::POEntry).to have_received(:new).with(
        msgid: 'attr interpolation',
        references: ['test.slim:8']
      )
    end

    it 'correctly extracts string from embedded Ruby code' do
      expect(PutText::POEntry).to have_received(:new).with(
        msgid: '1 multiline ruby',
        msgid_plural: '%d multiline rubies',
        references: ['test.slim:10']
      )
    end

    it 'correctly extracts string from splat attributes' do
      expect(PutText::POEntry).to have_received(:new).with(
        msgctxt: 'ctx',
        msgid: 'splat hash attr',
        references: ['test.slim:13']
      )
    end

    it 'correctly extracts string from text interpolation' do
      expect(PutText::POEntry).to have_received(:new).with(
        msgid: 'text interpolation',
        references: ['test.slim:21']
      )
    end

    it 'correctly extracts string from unescaped Ruby output code' do
      expect(PutText::POEntry).to have_received(:new).with(
        msgid: 'unescaped string',
        references: ['test.slim:23']
      )
    end
  end
end
