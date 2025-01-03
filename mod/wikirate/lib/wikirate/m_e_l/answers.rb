module Wikirate
  class MEL
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

      def researched_created
        created { researched_answers }
      end

      def researched_created_team
        created_team { researched_answers }
      end

      def researched_created_others
        created_others { researched_answers }
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
        answers.where("updated_at > #{period_ago} && updated_at <> created_at")
               .where.not editor_id: team_ids
      end

      def answers_community_verified
        answers_by_verification :community_verified
      end

      def answers_steward_verified
        answers_by_verification :steward_verified
      end

      def answers_checked
        verification_indexes = %i[community_verified steward_verified].map do |symbol|
          ::Answer.verification_index symbol
        end

        answers.joins("join cards on left_id = answer_id")
               .where("right_id = #{:checked_by.card_id}")
               .where("cards.updated_at > #{period_ago}")
               .where("cards.updater_id not in (?)", team_ids)
               .where(verification: verification_indexes)
      end

      private

      def researched_answers
        answers.where "route <> #{Answer.route_index :calculation}"
      end

      def answers_by_route symbol
        answers.where route: Answer.route_index(symbol)
      end

      def answers_by_verification symbol
        answers.where verification: ::Answer.verification_index(symbol)
      end
    end
  end
end
