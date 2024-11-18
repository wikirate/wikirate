class Record
  # Methods to fetch the data needed to initialize a new record lookup table entry.
  module EntryFetch
    # when calculating, the fetch mechanism is skipped in favor of bulk updates
    def fetch_calculating
      false
    end

    # don't change the value
    def fetch_overridden_value
      overridden_value
    end
  end
end
