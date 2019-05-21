class Card
  class AnswerQuery
    # fix a company to search for metrics with/without answers
    class FixedCompany < AnswerQuery
      SIMPLE_FILTERS = ::Set.new(%i[company_id latest]).freeze
      LIKE_FILTERS = ::Set.new(%i[name metric]).freeze

      # filter values are card names and have to be translated to card ids
      CARD_ID_FILTERS = ::Set.new(%i[metric_type research_policy]).freeze

      DB_COLUMN_MAP = { name: :metric_name,
                        metric: :metric_name,
                        research_policy: :policy_id,
                        metric_type: :metric_type_id,
                        wikirate_topic: :topic }.freeze
      # translate filter key to db column

      def initialize company_id, *args
        @company_id = company_id
        @company_card = Card.fetch company_id
        super *args
      end

      def prepare_filter_args filter
        super
        @filter_args[:company_id] = @company_card.id
      end

      def topic_query value
        metric_ids =
          Card.search right_plus: [Card::WikirateTopicID, { refer_to: value }],
                      return: :id
        restrict_to_ids :metric_id, metric_ids
      end
      alias wikirate_topic_query topic_query

      def project_query value
        metric_ids =
          Card.search referred_to_by: "#{value}+#{Card.fetch_name :metric}",
                      return: :id
        restrict_to_ids :metric_id, metric_ids
      end

      def importance_query value
        values = Array(value).map &:to_sym
        return if values.size == 3 || values.empty?
        return unless Auth.signed_in? # FIXME: use session votes

        wql = { type_id: MetricID, limit: 0, return: :id }
        wql.merge! vote_wql(values)
        restrict_to_ids :metric_id, Card.search(wql)
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
