class Card
  # Query for both researched AND NOT RESEARCHED answers
  class AllAnswerQuery < AnswerQuery
    include AllFiltering
    include AllSorting
    include Applicability
    include NotResearched

    PARTNER_TYPE_ID = { company: Card::WikirateCompanyID, metric: Card::MetricID }.freeze

    def initialize filter, sorting={}, paging={}
      @card_conditions = []
      @card_values = []
      @partner_ids = nil
      @cql_filter = {}
      super
    end

    def process_filters
      require_partner!
      add_card_condition "#{@partner}.type_id = ?", PARTNER_TYPE_ID[@partner]
      filter_applicability
      super
    end

    def main_query
      @main_query ||= Card.joins(partner_join).where(partner_where)
    end

    private

    # Currently these queries only work with a fixed company or metric
    # it is not yet possible to handle not-researched answers for multiple companies and
    # metrics in one query
    def require_partner!
      @partner =
        if single_metric?
          :company
        elsif single_company?
          :metric
        else
          raise "must have partner for status: all or none"
        end
    end

    # This left join is the essence of the search strategy.
    def partner_join
      "AS #{@partner} LEFT JOIN answers " \
      "ON #{@partner}.id = #{@partner}_id AND #{lookup_conditions}"
    end

    def partner_where
      "#{@partner}.trash is false AND #{card_conditions} "
    end

    def researched_card id
      Answer.find(id).card
    end

    def main_results
      Card.find_by_sql(main_results_sql).map do |rec|
        rec.id ? researched_card(rec.id) : not_researched_card(rec.name)
      end
    end

    def main_results_sql
      p = @partner
      sort_and_page do
        main_query.select "answers.id, #{p}.name, #{p}.left_id, #{p}.right_id"
      end.to_sql
    end
  end
end
