module RXGetText
  class POFile
    attr_accessor :entries

    def initialize(entries)
      @entries = entries
    end

    def to_s
      str_io = StringIO.new
      write_to(str_io)
      str_io.string
    end

    def write_to(io)
      deduplicate

      @entries.each_with_index do |entry, index|
        io.write("\n") unless index == 0
        io.write(entry.to_s)
      end
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
