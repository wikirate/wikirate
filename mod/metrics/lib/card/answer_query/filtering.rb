class Card
  class AnswerQuery
    # filter field handling
    module Filtering
      CARD_ID_MAP = {
        research_policy: :policy_id,
        metric_type: :metric_type_id,
        value_type: :value_type_id
      }.freeze

      SIMPLE_FILTERS = ::Set.new(%i[company_id metric_id latest numeric_value]).freeze
      CARD_ID_FILTERS = ::Set.new(CARD_ID_MAP.keys).freeze
      METRIC_FIELDS_FILTERS = ::Set.new(
        %i[title_id designer_id scorer_id policy_id metric_type_id value_type_id]
      )


      protected

      def simple_filters
        SIMPLE_FILTERS
      end

      def card_id_filters
        CARD_ID_FILTERS
      end

      def card_id_map
        CARD_ID_MAP
      end

      def normalize_filter_args
        @filter_args[:published] = true unless @filter_args.key? :published
      end

      def filter_table field
        if METRIC_FIELDS_FILTERS.include?(field.to_sym)
          @joins << :metric
          "metrics"
        else
          "answers"
        end
      end
    end


  end
end
