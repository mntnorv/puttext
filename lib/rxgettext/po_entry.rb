module RXGetText
  class POEntry
    NS_SEPARATOR = '|'

    PO_C_STYLE_ESCAPES = {
      "\n" => "\\n",
      "\r" => "\\r",
      "\t" => "\\t",
      "\\" => "\\\\",
      "\"" => "\\\""
    }.freeze

    attr_reader :msgid
    attr_reader :msgid_plural
    attr_reader :msgctxt
    attr_reader :references

    def initialize(attrs)
      id, ctx = extract_context(
        attrs[:msgid], attrs[:separator] || NS_SEPARATOR
      )

      @msgid        = id
      @msgctxt      = attrs[:msgctxt] || ctx
      @msgid_plural = attrs[:msgid_plural]
      @references   = attrs[:references] || []
    end

    def to_s
      str = ''

      # Add comments
      str = add_comment(str, ':', @references.join(' ')) if references?

      # Add id and context
      str = add_string(str, 'msgctxt', @msgctxt) if @msgctxt
      str = add_string(str, 'msgid', @msgid)

      # Add plural id and empty translations
      if plural?
        str = add_string(str, 'msgid_plural', @msgid_plural)
        str = add_string(str, 'msgstr[0]', '')
        str = add_string(str, 'msgstr[1]', '')
      else
        str = add_string(str, 'msgstr', '')
      end

      str
    end

    def references?
      @references.length > 0
    end

    def plural?
      !@msgid_plural.nil?
    end

    def unique_key
      [@msgid, @msgctxt]
    end

    def merge(other_entry)
      @references += other_entry.references
      self
    end

    private

    def extract_context(str, separator)
      parts = str.rpartition(separator)
      return parts[2], parts[0] == '' ? nil : parts[0]
    end

    def add_comment(str, comment_type, value)
      value.each_line do |line|
        str << '#'
        str << comment_type
        str << ' '
        str << line
        str << "\n"
      end

      str
    end

    def add_string(str, id, value)
      str << id
      str << ' '
      str << string_to_po(value)
      str << "\n"
    end

    def string_to_po(str)
      lines = po_escape_string(str).split('\n')

      if lines.length < 2
        "\"#{lines[0]}\""
      else
        po_str = "\"\""

        lines.each do |line|
          po_str << "\n\""
          po_str << line
          po_str << "\\n\""
        end

        po_str
      end
    end

    def po_escape_string(str)
      encoded = ''

      str.each_char do |char|
        if PO_C_STYLE_ESCAPES[char]
          encoded << PO_C_STYLE_ESCAPES[char]
        else
          encoded << char
        end
      end

      encoded
    end
  end
end
