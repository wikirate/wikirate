class Card
  # fix a metric to search for companies with/without answers
  module FixedMetric
    def base_key
      :metric_id
    end

    def subject_key
      :company_id
    end

    def subject_type_id
      WikirateCompanyID
    end

    def filter_wql
      return {} unless @filter.present?
      CompanyFilterQuery.new(@filter).to_wql
    end

    def sort_designer_name_wql
      :name
    end

    def new_name subject
      subject = Card.fetch_name(subject) if subject.is_a? Integer
      "#{@base_card.name}+#{subject}+#{new_name_year}"
    end
  end
end
