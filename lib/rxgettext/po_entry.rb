module RXGetText
  class POEntry
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
      @msgid        = attrs[:msgid]
      @msgid_plural = attrs[:msgid_plural]
      @msgctxt      = attrs[:msgctxt]
      @references   = attrs[:references]
    end

    def to_s
      str = ''

      if @references && @references.length > 0
        str = add_comment(str, ':', @references.join(' '))
      end

      str = add_string(str, 'msgctxt', @msgctxt) if @msgctxt
      str = add_string(str, 'msgid', @msgid)
      str = add_string(str, 'msgid_plural', @msgid_plural) if @msgid_plural
      str = add_string(str, 'msgstr', '')

      str
    end

    private

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

      if lines.length == 1
        '"' + str + '"'
      else
        po_str = "\"\"\n"
        lines.each do |line|
          po_str << '"'
          po_str << line
          po_str << "\\n\"\n"
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
