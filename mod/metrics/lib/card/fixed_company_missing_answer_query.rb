class Card
  # find for a fixed company all metrics without metric answers
  class FixedCompanyMissingAnswerQuery < MissingAnswerQuery
    def base_key
      :company_id
    end

    def subject_key
      :metric_id
    end

    def subject_type_id
      MetricID
    end

    def additional_filter_wql
      MetricFilterQuery.new(@filter).to_wql
    end

    def new_name subject
      "#{subject}+#{@base_card.name}+#{year}"
    end
  end
end
