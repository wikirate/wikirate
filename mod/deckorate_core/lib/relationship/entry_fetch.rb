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
      Card.fetch_id (inverse_metric_id || fetch_inverse_metric_id),
                    (object_company_id || fetch_object_company_id),
                    (year || fetch_year).to_s
    end

    def fetch_subject_company_id
      card.name.left_name.left_name.right.card_id
    end

    def fetch_object_company_id
      card.right_id
    end

    def fetch_imported
      return false unless (action = card.value_card.actions.last)

      action.comment == "imported"
    end

    def fetch_updated_at
      return card.updated_at unless (vc = card.value_card)

      [card.updated_at, vc.updated_at].compact.max
    end

    # note: latest flag indicates that relationship is part of latest answer,
    # NOT that relationship is the latest response for a given subject/object pair
    def fetch_latest
      return true unless (latest_year = latest_year_in_db)

      @new_latest = (latest_year < fetch_year)
      latest_year <= fetch_year
    end
  end
end
