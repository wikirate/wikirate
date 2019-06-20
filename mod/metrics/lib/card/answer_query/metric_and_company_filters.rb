class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module MetricAndCompanyFilters
      def industry_query value
        multi_company do
          restrict_by_wql :company_id, CompanyFilterQuery.industry_wql(value)
        end
      end

      def topic_query value
        multi_metric do
          restrict_by_wql :metric_id,
                          right_plus: [Card::WikirateTopicID, { refer_to: value }]
        end
      end
      alias wikirate_topic_query topic_query

      def project_query value
        multi_metric do
          restrict_by_wql :metric_id,
                          referred_to_by: "#{value}+#{:metric.cardname}"
        end
        multi_company do
          restrict_by_wql :company_id,
                          referred_to_by: "#{value}+#{:wikirate_company.cardname}"
        end
      end

      def importance_query value
        multi_metric do
          values = Array(value).map(&:to_sym)
          return if values.size == 3 || values.empty? || !Auth.signed_in?
          # FIXME: use session votes

          restrict_by_wql :metric_id, { type_id: MetricID }.merge(vote_wql(values))
        end
      end

      # SUPPORT METHODS
      def single_metric?
        @filter_args[:metric_id].is_a? Integer
      end

      def single_company?
        @filter_args[:company_id].is_a? Integer
      end

      def multi_metric
        return if single_metric?

        yield
      end

      def multi_company
        return if single_company?

        yield
      end

      def company_card
        return unless single_company?

        @company_card ||= Card[@filter_args[:company_id]]
      end

      def metric_card
        return unless single_metric?

        @metric_card ||= Card[@filter_args[:metric_id]]
      end

      # @param values [Array<Symbol>] has to contains one or two of the symbols
      #   :upvotes, :downvotes, :novotes
      # @return wql to find cards that the signed in user has (not) voted on
      # TODO: move this to voting mod
      def vote_wql values
        if values.include? :novotes
          not_directions = missing_directions(values)
          { not: linked_to_by_vote_wql(not_directions) }
        else
          linked_to_by_vote_wql values
        end
      end

      def linked_to_by_vote_wql array
        vote_pointers = array.map { |v| vote_pointer_name(v) }
        { linked_to_by: [:in] + vote_pointers }
      end

      def vote_pointer_name direction
        "#{Auth.current.name}+#{Card.fetch_name direction}"
      end

      def missing_directions directions
        %i[upvotes downvotes novotes] - directions
      end
    end
  end
end
