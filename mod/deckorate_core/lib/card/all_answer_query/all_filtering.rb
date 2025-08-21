class Card
  class AllAnswerQuery
    # handles the application of filters to the cards table
    # (as opposed to the answers lookup table.
    # that handling is in AnswerQuery::Filtering)
    module AllFiltering
      PARTNER_FILTER_QUERY = {
        company: CompanyFilterCql,
        metric: MetricFilterCql
      }.freeze

      PARTNER_CQL_FILTERS = {
        company: ::Set.new(%i[project country]),
        metric: ::Set.new(%i[project designer metric_type assessment bookmark])
      }.freeze

      # TEMPORARY HACK.  replace with metric lookup
      def filter_by_metric_keyword value
        restrict_partner_ids matching_metric_ids(value)
      end

      private

      def matching_metric_ids value
        Card.search type: :metric,
                    right: { name: [:match, value] },
                    return: :id
      end

      def process_filter_option key, value
        return super unless PARTNER_CQL_FILTERS[partner].include? key

        @cql_filter[key] = value
      end

      def filter key, value, operator=nil
        return super unless (partner_column = partner_field_map[key])

        condition = "#{partner}.#{partner_column} #{op_and_val operator, value}"
        add_card_condition condition, value
      end

      def restrict_by_cql _suffix, col, cql
        return super unless partner_field_map[col]

        cql.reverse_merge! return: :id, limit: 0
        restrict_by_subquery col, Card::Query.new(cql).sql
      end

      def restrict_by_subquery col, subquery
        return super unless (partner_column = partner_field_map[col])

        @card_conditions <<
          "#{partner}.#{partner_column} IN (#{subquery})"
      end

      def add_card_condition condition, value
        @card_conditions << " #{condition} "
        @card_values << value
      end

      def filter_by_company_filter table, condition_method, value
        @card_joins << "JOIN answers AS #{table} ON #{partner}.id = #{table}.company_id"
        add_card_condition CompanyFilterCql.send(condition_method), Array.wrap(value)
      end

      # map answer fields to partner card fields
      def partner_field_map
        @partner_field_map ||= %i[id name].each_with_object({}) do |fld, hash|
          hash["#{partner}_#{fld}".to_sym] = fld
        end
      end

      def card_conditions
        add_card_condition "#{partner}.id IN (?)", @partner_ids if @partner_ids.present?
        add_card_condition "#{partner}.id NOT IN (?)", @not_ids if @not_ids.present?
        @card_conditions << "#{partner}.id IN (#{cql_subquery})" if @cql_filter.present?
        condition_sql([@card_conditions.join(" AND ")] + @card_values)
      end

      # most metric and company constraints are handled in a cql subquery
      def cql_subquery
        statement = PARTNER_FILTER_QUERY[partner].new(@cql_filter).to_cql
        Card::Auth.as_bot do
          cq = Card::Query.new statement.merge(return: :id), ""
          cq.define_singleton_method(:full?) { false }
          cq.sql
        end
      end

      def restrict_partner_ids ids
        @partner_ids = @partner_ids.nil? ? ids : (@partner_ids & ids)
        @empty_result = true if @partner_ids.blank?
      end

      def restrict_not_partners_ids ids
        @not_ids = @not_ids.nil? ? ids : (@not_ids | ids)
      end

      def filtered_year
        year = @filter_args[:year]
        year unless year.blank? || year.to_s == "latest"
      end

      def restrict_lookup_ids col, ids
        return super unless col == partner_id_col

        restrict_partner_ids ids
      end

      def partner_id_col
        @partner_id_col ||= "#{partner}_id".to_sym
      end

      def not_researched!
        @card_conditions << "answers.id is null"
      end
    end
  end
end
