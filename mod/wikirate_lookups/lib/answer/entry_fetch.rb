class Answer
  # Methods to fetch the data needed to initialize a new answer lookup table entry.
  module EntryFetch
    def fetch_answer_id
      card.id
    end

    def fetch_year
      card.year.to_i
    end

    def fetch_creator_id
      card.creator_id || Card::Auth.current_id
    end

    def fetch_created_at
      card&.value_card&.created_at || created_at || Time.now
    end

    def fetch_editor_id
      card.value_card.updater_id if value_updated?
    end

    def fetch_updated_at
      return card.updated_at unless (vc = card.value_card)

      [card.updated_at, vc.updated_at].compact.max
    end

    def fetch_overridden_value
      ov = card.try :overridden_value
      ov.present? ? ov : nil
    end

    def fetch_calculating
      false
    end

    private

    def value_updated?
      return unless (vc = card.value_card)
      vc.updated_at && vc.updated_at > vc.created_at
    end
  end
end
