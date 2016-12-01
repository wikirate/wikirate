class Card
  class CompanyBasedMissingMetricAnswerQuery
    def initialize filter
      @filter = filter.clone
      @filter.delete :metric_value # if we are here this is "none"
      @metric_card = Card[@filter.delete(:metric_id)]
      @year = @filter.delete :year
    end

    def run
      all_missing
    end

    private

    # @return [Array<String]
    def filtered_companies_without_values
      Card.search(missing_wql.merge(return: :name))
    end

    def all_missing
      filtered_companies_without_values.map do |company_name|
        Card.new name: new_name(company_name), type_id: MetricValueID
      end
    end

    def missing_wql
      wql = {
        type_id: WikirateCompanyID,
        not: { id: ["in", *company_ids_of_existing_answers] }
      }
      return wql unless @filter
      wql.merge CompanyFilterQuery.new(@filter).to_wql
    end

    def new_name company
      "#{@metric_card.name}+#{company}+#{year}"
    end

    def company_ids_of_existing_answers
      where_args = { metric_id: @metric_card.id }
      if @year
        where_args[:year] = @year
      else
        where_args[:latest] = true
      end
      MetricAnswer.where(where_args).pluck(:company_id)
    end

    def year
      @year || Time.now.year
    end
  end
end
