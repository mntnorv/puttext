# frozen_string_literal: true

module PutText
  class POFile
    attr_accessor :entries

    # Create a new POFile
    # @param [Array<POEntry>] entries an array of POEntry objects, that should
    #   be placed in this file.
    def initialize(entries)
      @entries = entries
    end

    def to_s
      str_io = StringIO.new
      write_to(str_io)
      str_io.string
    end

    # Write the contents of this file to the specified IO object.
    # @param [IO] io the IO object to write the contents of the file to.
    def write_to(io)
      deduplicate

      @entries.each_with_index do |entry, index|
        io.write("\n") unless index == 0
        io.write(entry.to_s)
      end
    end

    def ==(other)
      @entries == other.entries
    end

    private

    def deduplicate
      uniq_entries = {}

      @entries.each do |entry|
        key = entry.unique_key

        if uniq_entries[key]
          uniq_entries[key].merge(entry)
        else
          uniq_entries[key] = entry
        end
      end

      @entries = uniq_entries.values
    end
  end
end
