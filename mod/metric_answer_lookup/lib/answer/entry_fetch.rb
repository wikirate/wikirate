class Answer
  # Methods to fetch the data needed to initialize a new answer lookup table entry.
  module EntryFetch
    def fetch_answer_id
      card.id
    end

    def fetch_company_id
      card.left.right_id
    end

    def fetch_metric_id
      metric_card.id
    end

    def fetch_record_id
      card.left_id || card.left.id
    end

    def fetch_metric_name
      card.name.left_name.left
    end

    def fetch_company_name
      card.name.left_name.right
    end

    def fetch_title_name
      card.name.parts.second
    end

    def fetch_record_name
      card.name.left
    end

    def fetch_year
      card.name.right.to_i
    end

    def fetch_imported
      return unless (action = card.value_card.actions.last)
      action.comment == "imported"
    end

    def fetch_designer_id
      metric_card.left_id
    end

    def fetch_creator_id
      card.creator_id
    end

    def fetch_editor_id
      card.updater_id if card.updated_at > card.created_at
    end

    def fetch_designer_name
      card.name.parts.first
    end

    def fetch_policy_id
      return unless (policy_pointer = metric_card.fetch(trait: :research_policy))
      policy_name = policy_pointer.item_names.first
      (pc = Card.quick_fetch(policy_name)) && pc.id
    end

    def fetch_metric_type_id
      return unless (metric_type_pointer = metric_card.fetch(trait: :metric_type))
      metric_type_name = metric_type_pointer.item_names.first
      (mtc = Card.quick_fetch(metric_type_name)) && mtc.id
    end

    def fetch_value
      card.value
    end

    def fetch_numeric_value
      return unless metric_card.numeric?
      to_numeric_value fetch_value
    end

    def fetch_updated_at
      return card.updated_at unless (vc = card.value_card)
      [card.updated_at, vc.updated_at].compact.max
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
  end
end
