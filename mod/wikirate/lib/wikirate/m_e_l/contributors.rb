module Wikirate
  class MEL
    # Contributor methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Contributors
      def contributors_direct
        contributors { direct_created }
      end

      def contributors_import
        contributors { import_created }
      end

      def contributors_api
        contributors { api_created }
      end

      def stewards_who_researched
        contributors "editor_id" do
          researched_answers.where editor_id: steward_ids
        end
      end

      private

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

      def contributors field="creator_id"
        yield.select(field).distinct
      end
    end
  end
end
