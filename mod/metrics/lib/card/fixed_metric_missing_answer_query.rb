class Card
  # find for a fixed metric all companies without metric answers
  class FixedMetricMissingAnswerQuery < MissingAnswerQuery
    def base_key
      :metric_id
    end

    def subject_key
      :company_id
    end

    def subject_type_id
      WikirateCompanyID
    end

    def additional_filter_wql
      CompanyFilterQuery.new(@filter).to_wql
    end

    def new_name subject
      "#{@base_card.name}+#{subject}+#{year}"
    end
  end
end
