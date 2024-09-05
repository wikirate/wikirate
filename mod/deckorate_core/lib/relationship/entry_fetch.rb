class Relationship
  # Methods to fetch the data needed to initialize a new answer lookup table entry.
  module EntryFetch
    def fetch_year
      card.year.to_i
    end

    def fetch_record_id
      card.name.left_name.left_name.card_id
    end

    def fetch_metric_id
      card.name.left_name.left_name.left_name.card_id
    end

    def fetch_inverse_metric_id
      metric_card.inverse_card.id
    end

    def fetch_inverse_answer_id
      metric_id = inverse_metric_id || fetch_inverse_metric_id
      company_id = object_company_id || fetch_object_company_id
      Card.id [metric_id, company_id, (year || fetch_year).to_s]
    end

    def fetch_subject_company_id
      card.name.left_name.left_name.right.card_id
    end

    def fetch_object_company_id
      card.right_id
    end

    def fetch_updated_at
      return card.updated_at unless (vc = card.value_card)

      [card.updated_at, vc.updated_at].compact.max
    end

    # note: latest flag indicates that relationship is part of latest answer,
    # NOT that relationship is the latest response for a given subject/object pair
    def fetch_latest
      l = answer.latest
      l.nil? ? answer.fetch_latest : l
    end
  end
end
