module Wikirate
  module MEL
    # metric methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Metrics
      def metrics_created
        created { metrics }
      end

      def metrics_researched_created
        created { metrics_by_type :researched }
      end

      def metrics_calculated_created
        created { metrics_by_type :formula, :rating, :score, :descendant }
      end

      def metrics_relationship_created
        created { metrics_by_type :inverse_relationship, :relationship }
      end

      def metric_designers_new
        new_designer_ids = designer_ids { created { metrics } }
        old_designer_ids = designer_ids { metrics.where("created_at <= #{period_ago}") }
        new_designer_ids - old_designer_ids
      end

      def metric_designers_mixed
        metrics_by_type(:formula, :rating, :score, :descendant).select do |metric|
          metric.dependee_metrics.find { |m| m.metric_designer_id != metric.designer_id }
        end
      end

      private

      def designer_ids
        yield.select(:designer_id).distinct.pluck(:designer_id)
      end

      # need the cards join for the created data
      def metrics
        Metric.joins "join cards on cards.id = metric_id"
      end

      def metrics_by_type *type_codes
        metrics.where metric_type_id: type_codes.map(&:card_id)
      end
    end
  end
end