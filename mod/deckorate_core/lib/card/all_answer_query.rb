class Card
  # Query for both researched AND NOT RESEARCHED answers
  class AllAnswerQuery < AnswerQuery
    include AllFiltering
    include AllSorting
    include Applicability
    include NotResearched

    PARTNER_TYPE_ID = { company: Card::CompanyID, metric: Card::MetricID }.freeze

    def initialize filter, sorting={}, paging={}
      @card_conditions = []
      @card_joins = []
      @card_values = []
      @partner_ids = nil
      @cql_filter = {}
      super
    end

    def process_filters
      add_card_condition "#{partner}.type_id = ?", PARTNER_TYPE_ID[partner]
      filter_applicability
      super
    end

    def main_query
      @main_query ||= Card.joins(partner_joins).where partner_where
    end

    private

    def partner_joins
      @card_joins.unshift("AS #{partner}").push partner_answer_join
    end

    # Currently these queries only work with a fixed company or metric
    # it is not yet possible to handle not-researched answers for multiple companies and
    # metrics in one query
    def partner
      @partner ||=
        if single_metric?
          :company
        elsif single_company?
          :metric
        else
          raise "must have partner for status: all or none"
        end
    end

    # This left join is the essence of the search strategy.
    def partner_answer_join
      "LEFT JOIN answers " \
      "ON #{partner}.id = answers.#{partner}_id AND #{lookup_conditions}"
    end

    def partner_where
      "#{partner}.trash is false AND #{card_conditions} "
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
      fields = "answers.id, #{partner}.name, #{partner}.left_id, #{partner}.right_id"
      @main_results_sql ||= sort_and_page { main_query.select fields }.to_sql
    end
  end
end
