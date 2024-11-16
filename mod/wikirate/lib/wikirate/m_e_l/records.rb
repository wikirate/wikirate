module Wikirate
  module MEL
    # Record methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Records
      def records
        Record
      end

      def calculations
        records_by_route :calculation
      end

      def import
        records_by_route :import
      end

      def direct
        records_by_route :direct
      end

      def api
        records_by_route :api
      end

      def records_created
        created { records }
      end

      def calculations_created
        created { records_by_route :calculation }
      end

      def import_created
        created { records_by_route :import }
      end

      def direct_created
        created { records_by_route :direct }
      end

      def api_created
        created { records_by_route :api }
      end

      def records_updated
        updated { records }
      end

      def records_community_verified
        records_by_verification :community_verified
      end

      def records_steward_verified
        records_by_verification :steward_verified
      end

      def records_checked
        verification_indexes = %i[community_verified steward_verified].map do |symbol|
          ::Record.verification_index symbol
        end

        records.joins("join cards on left_id = record_id")
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

      def records_by_route symbol
        records.where route: Record.route_index(symbol)
      end

      def records_by_verification symbol
        records.where verification: ::Record.verification_index(symbol)
      end

      def contributors
        yield.select("creator_id").distinct
      end
    end
  end
end
