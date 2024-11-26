module Wikirate
  module MEL
    # Answer methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Answers
      def answer
        Answer
      end

      def calculations
        answer_by_route :calculation
      end

      def import
        answer_by_route :import
      end

      def direct
        answer_by_route :direct
      end

      def api
        answer_by_route :api
      end

      def answer_created
        created { answer }
      end

      def calculations_created
        created { answer_by_route :calculation }
      end

      def import_created
        created { answer_by_route :import }
      end

      def direct_created
        created { answer_by_route :direct }
      end

      def api_created
        created { answer_by_route :api }
      end

      def answer_updated
        updated { answer }
      end

      def answer_community_verified
        answer_by_verification :community_verified
      end

      def answer_steward_verified
        answer_by_verification :steward_verified
      end

      def answer_checked
        verification_indexes = %i[community_verified steward_verified].map do |symbol|
          ::Answer.verification_index symbol
        end

        answer.joins("join cards on left_id = answer_id")
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

      def answer_by_route symbol
        answer.where route: Answer.route_index(symbol)
      end

      def answer_by_verification symbol
        answer.where verification: ::Answer.verification_index(symbol)
      end

      def contributors
        yield.select("creator_id").distinct
      end
    end
  end
end
