class Answer
  # Methods to fetch the data needed to initialize a new answer lookup table entry.
  module EntryFetch
    include MetricDetails
    include ValueDetails

    def fetch_answer_id
      card.id if card.id && card.value_card.id
    end

    def fetch_company_id
      Card.fetch_id fetch_record_name.right
    end

    def fetch_company_name
      Card.fetch_name(company_id || fetch_company_id)
    end

    def fetch_record_id
      card.left_id || Card.fetch_id(fetch_record_name)
    end

    def fetch_record_name
      card.name.left_name
    end

    def fetch_year
      card.name.right.to_i
    end

    def fetch_checkers
      return unless (cb = card.field(:checked_by)) && cb.checked?
      cb.checkers.join(", ")
    end

    def fetch_check_requester
      return unless (cb = card.field(:checked_by)) && cb.check_requested?
      cb.check_requester
    end

    def fetch_latest
      return true unless (latest_year = latest_year_in_db)
      @new_latest = (latest_year < fetch_year)
      latest_year <= fetch_year
    end

    def fetch_source_count
      source_field.item_names.size
    end

    def fetch_source_url
      return unless (url_card = source_field.first_card&.field(:wikirate_link))
      url_card.content.truncate(1024, omission: "")
    end

    def fetch_comments
      return nil unless (comment_card = Card.fetch [card.name, :discussion])
      comment_card.format(:text).render_core.gsub(/^\s*--.*$/,"").squish.truncate(1024)
    end

    private

    def source_field
      @source_field ||=
        Card.fetch [card.name, :source], new: { type_id: Card::PointerID }
    end
  end
end
