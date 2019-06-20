class Card
  class AnswerQuery
    # Query answers for a given company
    class FixedCompany < AnswerQuery
      FILTER_TRANSLATIONS =  { name: :metric_name,
                               metric: :metric_name,
                               research_policy: :policy_id,
                               metric_type: :metric_type_id }.freeze

      def initialize company_id, filter, sorting={}, paging={}
        @company = Card[company_id]
        filter[:company_id] = company_id
        super filter, sorting, paging
      end

      def subject
        :metric
      end

      def subject_type_id
        Card::MetricID
      end

      def new_name metric
        "#{metric}+#{@company.name}+#{new_name_year}"
      end

      def topic_query value
        restrict_by_wql :metric_id,
                        right_plus: [Card::WikirateTopicID, { refer_to: value }]
      end
      alias wikirate_topic_query topic_query

      def project_query value
        restrict_by_wql :metric_id,
                        referred_to_by: "#{value}+#{:metric.cardname}"
      end

      def importance_query value
        values = Array(value).map(&:to_sym)
        return if values.size == 3 || values.empty? || !Auth.signed_in?
        # FIXME: use session votes

        restrict_by_wql :metric_id, { type_id: MetricID }.merge(vote_wql(values))
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
