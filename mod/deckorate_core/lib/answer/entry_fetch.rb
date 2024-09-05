class Answer
  # Methods to fetch the data needed to initialize a new answer lookup table entry.
  module EntryFetch
    # NOTE: the created and updated fields have a logic that differs slightly
    # from the answer card

    def fetch_creator_id
      card.creator_id || Card::Auth.current_id
    end

    def fetch_created_at
      card&.value_card&.created_at || created_at || Time.now
    end

    def fetch_editor_id
      card.value_card.updater_id if value_updated?
    end

    # I'm not sure this is still needed.  value card updates should update the card
    # test and, if possible, remove
    def fetch_updated_at
      return card.updated_at unless (vc = card.value_card)

      [card.updated_at, vc.updated_at].compact.max
    end

    # when calculating, the fetch mechanism is skipped in favor of bulk updates
    def fetch_calculating
      false
    end

    # don't change the value
    def fetch_overridden_value
      overridden_value
    end

    private

    def value_updated?
      return unless (vc = card.value_card)&.real?

      vc.updated_at && vc.updated_at > vc.created_at
    end
  end
end
