module Wikirate
  # methods in support of tracking details for
  # Monitoring, Evaluation, and Learning
  module MEL
    extend Metrics
    extend Records
    extend Datasets
    extend Flags

    class << self
      PERIOD = "1 month".freeze

      COLUMNS = {
        records: "Records Total",
        calculations: "Records total calculated",
        import: "Records total import",
        direct: "Records total direct",
        api: "Records total API",
        records_created: "Records created",
        calculations_created: "Records created calculated",
        import_created: "Records created import",
        direct_created: "Records created direct",
        api_created: "Records created API",
        relationships: "Relationships total",
        relationships_created: "Relationships created",
        records_updated: "Records updated",
        records_community_verified: "Records verified by community total",
        records_steward_verified: "Records verified by steward total",
        records_checked: "Records checked",
        contributors_direct: "Contributors direct",
        contributors_import: "Contributors import",
        contributors_api: "Contributors API",
        flags_created: "Flags created",
        flags_wrong_value: "Flagged wrong value",
        flags_wrong_company: "Flagged wrong company",
        flags_wrong_year: "Flagged wrong year",
        flags_other_subject: "Flagged other",
        flags_closed: "Flagged closed",
        metrics_created: "Metrics created",
        metrics_researched_created: "Research metrics created",
        metrics_calculated_created: "Calculated metrics created",
        metrics_relation_created: "Relation metrics created",
        metric_designers_new: "Metric designers new",
        metric_designers_mixed: "Metrics mixed designers",
        datasets_created: "Datasets created",
        datasets_complete: "Datasets complete",
        datasets_almost: "Datasets almost complete",
        datasets_majority: "Datasets majority complete",
        datasets_incomplete: "Datasets majority incomplete"
      }.freeze

      NO_COUNT_REGEX = /^flags_(wrong|other)|dataset/

      def titles
        COLUMNS.values
      end

      def dump
        puts csv_content
      end

      def csv_content
        m = measure
        CSV.generate do |csv|
          csv << m.keys
          csv << m.values
        end
      end

      def measure
        COLUMNS.each_with_object({}) do |(key, column), hash|
          Card::Cache.reset_temp
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

      def cql_count cql
        Card.search cql.merge(return: :count)
      end
    end
  end
end
