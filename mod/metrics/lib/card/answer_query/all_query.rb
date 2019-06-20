class Card
  class AnswerQuery
    class AllQuery < AnswerQuery
      PARTNER_TYPE_ID = { company: WikirateCompanyID, metric: MetricID }.freeze
      PARTNER_FILTER_QUERY = {
        company: CompanyFilterQuery, metric: MetricFilterQuery
      }.freeze
      PARTNER_CQL_FILTERS = {
        company: ::Set.new([:project]),
        metric: ::Set.new(%i[project designer metric_type research_policy importance])
      }.freeze

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

      def run
        run_result do
          card_query.map do |rec|
            rec.id ? lookup_answer_card(rec.id) : new_answer_card(rec.name)
          end
        end
      end

      def count
        count_result { select_all(card_select_sql("count(*) as count")).first["count"] }
      end

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

      def lookup_answer_card id
        Answer.find(id).card
      end

      def new_answer_card name
        Card.new name: new_name(name), type_id: MetricAnswerID
      end

      def new_name partner_name
        if @partner == :company
          Card::Name[metric_card.name, partner_name, new_name_year]
        else
          Card::Name[partner_name, company_card.name, new_name_year]
        end
      end

      def new_name_year
        @new_name_year ||= determine_new_name_year.to_s
      end

      def determine_new_name_year
        year = @filter_args[:year]
        year.blank? || year.to_s == "latest" ? Time.now.year : year
      end

      def card_query
        Card.find_by_sql(card_select_sql("answers.id, #{@partner}.name"))
      end

      def card_select_sql fields
        "SELECT #{fields} " \
        "FROM cards AS #{@partner} " \
        "LEFT JOIN answers ON #{@partner}.id = #{@partner}_id AND #{answer_conditions} " \
        "WHERE #{@partner}.trash is false AND #{card_conditions} "
      end

      def select_all sql
        ActiveRecord::Base.connection.select_all sql
      end

      def restrict_answer_ids col, ids
        col == partner_id_col ? (@card_ids += ids) : super
      end

      def partner_id_col
        @partner_id_col ||= "#{@partner}_id".to_sym
      end

      def require_partner!
        if single_metric?
          @partner = :company
        elsif single_company?
          @partner = :metric
        end
        raise "must have partner for status: all or none" unless @partner
      end

      def handle_not_researched
        @card_conditions << "answers.id is null" if status_filter == :none
      end

      # map answer fields to partner card fields
      def partner_field_map
        @partner_field_map ||= %i[id name].each_with_object({}) do |fld, hash|
          hash["#{@partner}_#{fld}".to_sym] = fld
        end
      end

      def process_filter_option key, value
        return super unless PARTNER_CQL_FILTERS[@partner].include? key

        @cql_filter[key] = value
      end

      def filter key, value, operator=nil
        return super unless (partner_column = partner_field_map[key])

        condition = "#{@partner}.#{partner_column} #{op_and_val operator, value}"
        add_card_condition condition, value
      end

      def add_card_condition condition, value
        @card_conditions << " #{condition} "
        @card_values << value
      end

      def card_conditions
        add_card_condition "#{@partner}.id IN (?)", @card_ids if @card_ids.present?
        @card_conditions << " #{@partner}.id IN (#{cql_subquery})" if @cql_filter.present?
        condition_sql([@card_conditions.join(" AND ")] + @card_values)
      end

      def cql_subquery
        statement = PARTNER_FILTER_QUERY[@partner].new(@cql_filter).to_wql
        Card::Auth.as_bot do
          cq = Card::Query.new statement.merge(return: :id), ""
          cq.define_singleton_method(:full?) { false }
          cq.sql
        end
      end
    end
  end
end
