class Answer
  # Methods to fetch the data needed to initialize a new answer lookup table entry.
  module EntryFetch
    include ValueDetails

    def fetch_answer_id
      card.id
    end

    def fetch_year
      card.year.to_i
    end

    def fetch_checkers
      return unless (cb = card.field(:checked_by)) && cb.checked?
      cb.checkers.join(", ")
    end

    def fetch_check_requester
      return unless (cb = card.field(:checked_by)) && cb.check_requested?
      cb.check_requester
    end

    def fetch_comments
      return nil unless (comment_card = Card.fetch [card.name, :discussion])
      comment_card.format(:text).render_core.gsub(/^\s*--.*$/, "").squish.truncate 1024
    end
  end
end
