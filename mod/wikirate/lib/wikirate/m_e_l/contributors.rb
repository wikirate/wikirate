module Wikirate
  module MEL
    # Contributor methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Contributors
      def contributors_direct
        contributors { direct }
      end

      def contributors_import
        contributors { import }
      end

      def contributors_api
        contributors { api }
      end

      def stewards_who_researched
        contributors "editor_id" do
          researched_answers.where editor_id: steward_ids
        end
      end

      private

      def contributors field="creator_id"
        yield.select(field).distinct
      end
    end
  end
end
