module Wikirate
  module MEL
    # Answer methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Answers
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

      private

      def answers_by_route symbol
        answers.where route: Answer.route_index(symbol)
      end

      def answers_by_verification symbol
        answers.where verification: Answer.verification_index(symbol)
      end

      def contributors
        yield.select("creator_id").distinct
      end
    end
  end
end
