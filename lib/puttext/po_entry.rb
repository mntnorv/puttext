module PutText
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

    # Create a new POEntry
    #
    # @param [Hash] attrs
    # @option attrs [String] :msgid the id of the string (the string that needs
    #   to be translated). Can include a context, separated from the id by
    #   {NS_SEPARATOR} or by the specified :separator.
    # @option attrs [String] :msgid_plural the pluralized id of the string (the
    #   pluralized string that needs to be translated).
    # @option attrs [String] :msgctxt the context of the string.
    # @option attrs [Array<String>] :references a list of files with line
    #   numbers, pointing to where the string was found.
    # @option attrs [String] :separator the separator of context from id in
    #   :msgid.
    def initialize(attrs)
      id, ctx = extract_context(
        attrs[:msgid], attrs[:separator] || NS_SEPARATOR
      )

      @msgid        = id
      @msgctxt      = attrs[:msgctxt] || ctx
      @msgid_plural = attrs[:msgid_plural]
      @references   = attrs[:references] || []
    end

    # Convert the entry to a string representation, to be written to a .po file
    # @return [String] a string representation of the entry.
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

    # Check if the entry has any references.
    # @return [Boolean] whether the entry has any references.
    def references?
      @references.length > 0
    end

    # Check if the entry has a plural form.
    # @return [Boolean] whether the entry has a plural form.
    def plural?
      !@msgid_plural.nil?
    end

    # Return an object uniquely identifying this entry. The returned object can
    # be used to find duplicate entries.
    # @return an object uniquely identifying this entry.
    def unique_key
      [@msgid, @msgctxt]
    end

    # Merge this entry with another entry. Modifies the current entry in place.
    # Currently, merges only the references, and leaves other attributes of the
    # current entry untouched.
    #
    # @param [POEntry] other_entry the entry to merge with.
    # @return [POEntry] the merged entry.
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
      lines = str.split("\n", -1)

      if lines.length == 0
        '""'
      elsif lines.length == 1
        "\"#{po_escape_string(lines[0])}\""
      else
        po_str = "\"\""

        lines.each_with_index do |line, index|
          next if (index == lines.length - 1) && line.empty?

          po_str << "\n\""
          po_str << po_escape_string(line)
          po_str << "\\n" unless index == lines.length - 1
          po_str << '"'
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
