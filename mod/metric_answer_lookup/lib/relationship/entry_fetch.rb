class Relationship
  # Methods to fetch the data needed to initialize a new answer lookup table entry.
  module EntryFetch
    def fetch_answer_id
      card.left_id
    end

    def fetch_relationship_id
      card.id
    end

    def fetch_record_id
      Card.fetch_id(card.name.left_name.left_name)
    end

    def fetch_metric_id
      Card.fetch_id card.name.left_name.left_name.left_name
    end

    def fetch_subject_company_id
      Card.fetch_id card.name.left_name.left_name.right
    end

    def fetch_object_company_id
      card.right_id
    end

    def fetch_subject_company_name
      Card.fetch_name(subject_company_id || fetch_subject_company_id)
    end

    def fetch_object_company_name
      Card.fetch_name(object_company_id || fetch_object_company_id)
    end

    def fetch_year
      card.name.left_name.right.to_i
    end

    def fetch_value
      card.value
    end

    def fetch_numeric_value
      return unless metric_card.numeric?
      to_numeric_value fetch_value
    end

    def fetch_imported
       return false unless (action = card.value_card.actions.last)
       action.comment == "imported"
    end

    def fetch_updated_at
      return card.updated_at unless (vc = card.value_card)
      [card.updated_at, vc.updated_at].compact.max
    end

    def fetch_latest
      return true unless (latest_year = latest_year_in_db)
      @new_latest = (latest_year < fetch_year)
      latest_year <= fetch_year
    end
  end
end
