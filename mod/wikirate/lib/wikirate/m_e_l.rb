module Wikirate
  # methods in support of tracking details for
  # Monitoring, Evaluation, and Learning
  module MEL
    extend Metrics
    extend Answers
    extend Datasets
    extend Flags
    extend Contributors

    class << self
      PERIOD = "1 month".freeze

      COLUMNS = {
        answers: "Answers Total",
        calculations: "Answers total calculated",
        import: "Answers total import",
        direct: "Answers total direct",
        api: "Answers total API",
        answers_created: "Answers created",
        researched_created: "Answers created researched",
        researched_created_team: "Answers created by team - researched",
        researched_created_others: "Answers created not by team - researched",
        calculations_created: "Answers created calculated",
        import_created: "Answers created import",
        direct_created: "Answers created direct",
        api_created: "Answers created API",
        answers_updated: "Answers updated",
        answers_community_verified: "Answers verified by community total",
        answers_steward_verified: "Answers verified by steward total",
        answers_checked: "Answers verified",
        relationships: "Relationships total",
        relationships_created: "Relationships created",
        relationships_created_team: "Relationships created by team",
        relationships_created_others: "Relationships created not by team",
        contributors_direct: "Contributors direct",
        contributors_import: "Contributors import",
        contributors_api: "Contributors API",
        stewards_who_researched: "Stewards who researched",
        flags_created: "Flags created",
        flags_wrong_value: "Flagged wrong value",
        flags_wrong_company: "Flagged wrong company",
        flags_wrong_year: "Flagged wrong year",
        flags_other_subject: "Flagged other",
        flags_closed: "Flagged closed",
        metrics_created: "Metrics created",
        metrics_created_team: "Metrics created by team",
        metrics_created_others: "Metrics created not by team",
        metrics_researched_created: "Research metrics created",
        metrics_calculated_created: "Calculated metrics created",
        metrics_relation_created: "Relation metrics created",
        metric_designers_new: "Metric designers new",
        metric_designers_mixed: "Metrics mixed designers",
        datasets_created: "Datasets created",
        datasets_created_stewards: "Datasets created by stewards",
        datasets_category_complete: "Datasets complete",
        datasets_category_almost: "Datasets almost complete",
        datasets_category_majority: "Datasets majority complete",
        datasets_category_incomplete: "Datasets majority incomplete",
        attributions_created: "Attributions created",
        research_groups_created: "Research groups created",
        research_groups_created_stewards: "Research groups created by stewards",
      }.freeze

      NO_COUNT_REGEX = /^flags_(wrong|other)|datasets_category/

      def titles
        COLUMNS.values
      end

      def record
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
          # puts "measure #{key}"
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

      def relationships_created_team
        created_team { relationships }
      end

      def relationships_created_others
        created_others { relationships }
      end

      def attributions_created
        created { cards_of_type :attribution }
      end

      def research_groups_created
        created { research_groups }
      end

      def research_groups_created_stewards
        created_stewards { research_groups }
      end

      private

      def cards_of_type codename
        cards.where type_id: codename.card_id
      end

      def research_groups
        cards_of_type :research_group
      end

      def cards
        Card.where trash: false
      end

      def created
        yield.where "created_at > #{period_ago}"
      end

      def team_ids
        @team_ids ||= Card::Set::Self::WikirateTeam.member_ids
      end

      def steward_ids
        @steward_ids ||= (
          Card::Set::Self::Steward.always_ids +
            Metric.pluck("distinct designer_id") +
            Card.search(referred_to_by: { right: :steward }, return: :id)
        ).uniq
      end

      def created_team &block
        created(&block).where creator_id: team_ids
      end

      def created_others &block
        created(&block).where.not creator_id: team_ids
      end

      def created_stewards &block
        created(&block).where creator_id: steward_ids
      end

      def updated
        yield.where("updated_at > #{period_ago} && updated_at <> created_at")
             .where.not editor_id: team_ids
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
