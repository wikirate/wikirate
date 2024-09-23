module Wikirate
  # methods in support of tracking details for
  # Monitoring, Evaluation, and Learning
  module MEL
    extend Metrics
    extend Answers
    extend Datasets

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
        datasets_complete: "Datasets complete",
        datasets_almost: "Datasets almost complete",
        datasets_majority: "Datasets majority complete",
        datasets_incomplete: "Datasets majority incomplete"
      }.freeze

      NO_COUNT_REGEX = /^flag|dataset/

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

      def relationships
        Relationship
      end

      def relationships_created
        created { relationships }
      end

      def flags_created
        created { cards.where type_id: :flag.card_id }.count
      end

      private

      def cards
        Card.where trash: false
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

      def flag_cql
        { type: :flag }
      end

      def cql_count cql
        Card.search cql.merge(return: :count)
      end
    end
  end
end
