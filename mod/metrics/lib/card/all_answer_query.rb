class Card
  # Query for both researched AND NOT RESEARCHED answers
  class AllAnswerQuery < AnswerQuery
    include AllFiltering
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

    # @return [Array]
    def run
      run_result do
        card_query.map do |rec|
          rec.id ? researched_card(rec.id) : not_researched_card(rec.name)
        end
      end
    end

    # @return [Integer]
    def count
      count_result { select_all(card_select_sql("count(*) as count")).first["count"] }
    end

    # @return [Hash] with a key for each group and a count as the value
    def count_by_group group
      sql = %(#{card_select_sql "count(*) as count, #{group} as groop"} GROUP BY groop)
      select_all(sql).each_with_object({}) do |row, hash|
        hash[row["groop"]] = row["count"]
      end
    end

    private

    def status_groups
      @status_groups ||= super.merge(none: nil)
    end

    def researched_card id
      Answer.find(id).card
    end

    def card_query
      Card.find_by_sql(card_select_sql("answers.id, #{@partner}.name"))
    end

    # This left join is the essence of the search strategy.
    def card_select_sql fields
      "SELECT #{fields} " \
      "FROM cards AS #{@partner} " \
      "LEFT JOIN answers ON #{@partner}.id = #{@partner}_id AND #{answer_conditions} " \
      "WHERE #{@partner}.trash is false AND #{card_conditions} "
    end

    def select_all sql
      ActiveRecord::Base.connection.select_all sql
    end

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
  end
end
