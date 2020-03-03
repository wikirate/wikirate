class Answer
  # Methods to fetch the data needed to initialize a new answer lookup table entry.
  module EntryFetch
    def fetch_answer_id
      card.id if card.id && card.value_card.id
    end

    def fetch_company_id
      Card.fetch_id fetch_record_name.right
    end

    def fetch_metric_id
      Card.fetch_id fetch_record_name.left
    end

    def fetch_record_id
      card.left_id || Card.fetch_id(fetch_record_name)
    end

    def fetch_metric_name
      Card.fetch_name(metric_id || fetch_metric_id)
    end

    def fetch_company_name
      Card.fetch_name(company_id || fetch_company_id)
    end

    def fetch_title_name
      card.name.parts.second
    end

    def fetch_record_name
      card.name.left_name
    end

    def fetch_year
      card.name.right.to_i
    end

    def fetch_imported
      return false unless (action = card.value_card.actions.last)
      action.comment == "imported"
    end

    def fetch_designer_id
      metric_card.left_id
    end

    def fetch_creator_id
      card.creator_id || Card::Auth.current_id
    end

    def fetch_editor_id
      card.value_card.updater_id if value_updated?
    end

    def fetch_designer_name
      card.name.parts.first
    end

    def fetch_policy_id
      policy_name = metric_card.fetch(:research_policy)&.first_name
      Card.fetch_id policy_name if policy_name
    end

    def fetch_metric_type_id
      metric_card&.metric_type_id
    end

    def fetch_value
      card.value
    end

    def fetch_numeric_value
      return unless metric_card.numeric? || metric_card.relationship?
      to_numeric_value fetch_value
    end

    def fetch_updated_at
      return card.updated_at unless (vc = card.value_card)
      [card.updated_at, vc.updated_at].compact.max
    end

    def fetch_created_at
      card&.value_card&.created_at || created_at || Time.now
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

    def value_updated?
      return unless (vc = card.value_card)
      vc.updated_at && vc.updated_at > vc.created_at
    end

    def fetch_overridden_value
      ov = card.try :overridden_value
      ov.present? ? ov : nil
    end

    def fetch_calculating
      false
    end

    def fetch_source_count
      source_field.item_names.size
    end

    def fetch_source_url
      return unless (url_card = source_field.first_card&.field(:wikirate_link))
      url_card.content.truncate(1024, omission: "")
    end

    def source_field
      @source_field ||=
        Card.fetch [card.name, :source], new: { type_id: Card::PointerID }
    end

    def fetch_comments
      return nil unless (comment_card = Card.fetch [card.name, :discussion])
      comment_card.format(:text).render_core.gsub(/^\s*--.*$/,"").squish.truncate(1024)
    end
  end
end
