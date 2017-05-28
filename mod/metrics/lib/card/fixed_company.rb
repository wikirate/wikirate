class Card
  # fix a company to search for metrics with/without answers
  module FixedCompany
    def base_key
      :company_id
    end

    def subject_key
      :metric_id
    end

    def subject_type_id
      MetricID
    end

    def subject_filter_wql
      return {} unless @filter
      MetricFilterQuery.new(@filter).to_wql
    end

    def new_name subject
      subject = Card.fetch_name(subject) if subject.is_a? Integer
      "#{subject}+#{@base_card.name}+#{year}"
    end
  end
end
