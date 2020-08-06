class Answer
  module EntryFetch
    # fetching metric-related answer details
    module MetricDetails
      def fetch_metric_id
        Card.fetch_id fetch_record_name.left
      end

      def fetch_designer_id
        # FIXME: wrong for scores
        metric_card.left_id
      end

      def fetch_title_id
        # FIXME: wrong for scores
        metric_card.right_id
      end

      def fetch_policy_id
        policy_name = metric_card.fetch(:research_policy)&.first_name
        Card.fetch_id policy_name if policy_name
      end

      def fetch_metric_type_id
        metric_card&.metric_type_id
      end
    end
  end
end
