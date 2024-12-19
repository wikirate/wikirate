module Wikirate
  module MEL
    # Helper methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Helper
      def cards
        Card.where trash: false
      end

      def cards_of_type codename
        cards.where type_id: codename.card_id
      end

      def created
        yield.where "created_at > #{period_ago}"
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
    end
  end
end
