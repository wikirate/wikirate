module Wikirate
  class MEL
    # Relationship methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Relationships
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
    end
  end
end
