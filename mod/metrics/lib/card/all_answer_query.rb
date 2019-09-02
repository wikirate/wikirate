class Card
  # Query for both researched AND NOT RESEARCHED answers
  class AllAnswerQuery < AnswerQuery
    include AllFiltering
    include AllSorting
    include NotResearched

    PARTNER_TYPE_ID = { company: WikirateCompanyID, metric: MetricID }.freeze

    def initialize filter, sorting={}, paging={}
      @filter_args = filter # duplicated, but must happen before require_partner!

      @card_conditions = []
      @card_values = []
      @card_ids = []
      @cql_filter = {}

      require_partner!
      add_card_condition "#{@partner}.type_id = ?", PARTNER_TYPE_ID[@partner]
      handle_not_researched

      super
    end

    def main_query
      Card.joins(partner_join).where(partner_where)
    end

    private

    # Currently these queries only work with a fixed company or metric
    # it will be possible to handle not-researched answers for multiple companies and
    # metrics, but this is not yet supported.
    def require_partner!
      if single_metric?
        @partner = :company
      elsif single_company?
        @partner = :metric
      end
      raise "must have partner for status: all or none" unless @partner
    end

    # This left join is the essence of the search strategy.
    def partner_join
      "AS #{@partner} LEFT JOIN answers " \
      "ON #{@partner}.id = #{@partner}_id AND #{answer_conditions}"
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
      sort_and_page { main_query.select "answers.id, #{@partner}.name" }.to_sql
    end
  end
end
