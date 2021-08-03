class Card
  class AllAnswerQuery
    # handles the application of filters to the cards table
    # (as opposed to the answers lookup table.
    # that handling is in AnswerQuery::Filtering)
    module AllFiltering
      PARTNER_FILTER_QUERY = {
        company: CompanyFilterQuery, metric: MetricFilterQuery
      }.freeze

      PARTNER_CQL_FILTERS = {
        company: ::Set.new(%i[project country]),
        metric: ::Set.new(%i[project designer metric_type research_policy bookmark])
      }.freeze

      # TEMPORARY HACK.  replace with metric lookup
      def metric_name_query value
        restrict_partner_ids matching_metric_ids(value)
      end

      private

      def matching_metric_ids value
        Card.search type_id: Card::MetricID,
                    right: { name: [:match, value] },
                    return: :id
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

      # map answer fields to partner card fields
      def partner_field_map
        @partner_field_map ||= %i[id name].each_with_object({}) do |fld, hash|
          hash["#{@partner}_#{fld}".to_sym] = fld
        end
      end

      def card_conditions
        add_card_condition "#{@partner}.id IN (?)", @partner_ids if @partner_ids.present?
        add_card_condition "#{@partner}.id NOT IN (?)", @not_ids if @not_ids.present?
        @card_conditions << "#{@partner}.id IN (#{cql_subquery})" if @cql_filter.present?
        condition_sql([@card_conditions.join(" AND ")] + @card_values)
      end

      # most metric and company constraints are handled in a cql subquery
      def cql_subquery
        statement = PARTNER_FILTER_QUERY[@partner].new(@cql_filter).to_cql
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

      def filter_applicability
        if @partner == :company
          restrict_to_applicable_companies
          validate_year_restriction
        else
          restrict_to_applicable_metrics
        end
      end

      def restrict_to_applicable_companies
        return unless (ids = metric_card&.company_group_card&.company_ids)&.present?

        restrict_partner_ids ids
      end

      def restrict_to_applicable_metrics
        if (never_ids = company_card&.inapplicable_metric_ids)&.present?
          restrict_not_partners_ids never_ids
        end

        if (not_now_ids = year_card&.inapplicable_metric_ids)&.present?
          restrict_not_partners_ids not_now_ids
        end
      end

      def year_card
        year = @filter_args[:year]&.to_s
        return if year.blank? || year == "latest"

        Card[year]
      end

      # if there are year filters and year applicability restrictions,
      # there must be at least one year in common to find a result.
      def validate_year_restriction
        return unless (filtered_years = Array.wrap(@filter_args[:year]))&.present?
        return unless (applicable_years = metric_card&.year_card&.item_names)&.present?

        @empty_result = true unless (filtered_years & applicable_years).present?
      end

      def restrict_lookup_ids col, ids
        return super unless col == partner_id_col

        restrict_partner_ids ids
      end

      def partner_id_col
        @partner_id_col ||= "#{@partner}_id".to_sym
      end

      def not_researched!
        @card_conditions << "answers.id is null"
      end
    end
  end
end
