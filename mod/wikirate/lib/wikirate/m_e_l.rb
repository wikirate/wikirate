module Wikirate
  # methods in support of tracking details for
  # Monitoring, Evaluation, and Learning
  module MEL
    class << self
      PERIOD = "1 month".freeze

      COLUMNS = {
        answers: "Answers Total",
        calculations: "Answers total calculated",
        import: "Answers total import",
        direct: "Answers total direct",
        api: "Answers total API",
        answers_created: "Answers created",
        calculations_created: "Answers created calculated",
        import_created: "Answers created import",
        direct_created: "Answers created direct",
        api_created: "Answers created API",
        relationships: "Relationships total",
        relationships_created: "Relationships created",
        answers_updated: "Answers updated",
        answers_community_verified: "Answers verified by community total",
        answers_steward_verified: "Answers verified by steward total",
        answers_checked: "Answers checked",
        contributors_direct: "Contributors direct",
        contributors_import: "Contributors import",
        contributors_api: "Contributors API",
        flags_created: "Flags created",
        # flags_wrong_value: "Flagged wrong value",
        # flags_wrong_company: "Flagged wrong company",
        # flags_wrong_year: "Flagged wrong year",
        # flags_other: "Flagged other",
        # flags_closed: "Flagged closed",
        metrics_created: "Metrics created",
        metrics_researched_created: "Research metrics created",
        metrics_calculated_created: "Calculated metrics created",
        metrics_relationship_created: "Relationship metrics created",
        # Metric designers new
        # Metrics mixed designers
        datasets_created: "Datasets created",
        # Datasets complete
        # Datasets almost complete
        # Datasets majority complete
        # Datasets majority incomplete
      }.freeze

      NO_COUNT_REGEX = /^flag/

      def dump
        puts measure
      end

      def measure
        COLUMNS.each_with_object({}) do |(key, column), hash|
          response = send key
          response = response.count unless key.match? NO_COUNT_REGEX
          hash[column] = response
        end
      end

      def answers
        Answer
      end

      def calculations
        answers_by_route :calculation
      end

      def import
        answers_by_route :import
      end

      def direct
        answers_by_route :direct
      end

      def api
        answers_by_route :api
      end

      def answers_created
        created { answers }
      end

      def calculations_created
        created { answers_by_route :calculation }
      end

      def import_created
        created { answers_by_route :import }
      end

      def direct_created
        created { answers_by_route :direct }
      end

      def api_created
        created { answers_by_route :api }
      end

      def relationships
        Relationship
      end

      def relationships_created
        created { relationships }
      end

      def answers_updated
        updated { answers }
      end

      def answers_community_verified
        answers_by_verification :community_verified
      end

      def answers_steward_verified
        answers_by_verification :steward_verified
      end

      def answers_checked
        verification_indexes = %i[community_verified steward_verified].map do |symbol|
          Answer.verification_index symbol
        end

        answers.joins("join cards on left_id = answer_id")
               .where("right_id = #{:checked_by.card_id}")
               .where("cards.updated_at > #{period_ago}")
               .where(verification: verification_indexes)
      end

      def contributors_direct
        contributors { direct }
      end

      def contributors_import
        contributors { import }
      end

      def contributors_api
        contributors { api }
      end

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

      def datasets_created
        created { datasets }
      end

      def flags_created
        created { cards.where type_id: :flag.card_id }.count
      end

      private

      def datasets
        cards.where type_id: :dataset.card_id
      end

      def cards
        Card.where trash: false
      end

      def answers_by_route symbol
        answers.where route: Answer.route_index(symbol)
      end

      def answers_by_verification symbol
        answers.where verification: Answer.verification_index(symbol)
      end

      def metrics
        Metric.joins "join cards on cards.id = metric_id"
      end

      def metrics_by_type *type_codes
        metrics.where metric_type_id: type_codes.map(&:card_id)
      end

      def created
        yield.where "created_at > #{period_ago}"
      end

      def updated
        yield.where "updated_at > #{period_ago} && updated_at <> created_at"
      end

      def period_ago
        "now() - INTERVAL #{PERIOD}"
      end

      def contributors
        yield.select("creator_id").distinct
      end

      def flag_cql
        { type: :flag }
      end

      def cql_count cql
        Card.search cql.merge(return: :count)
      end
    end
  end
end
