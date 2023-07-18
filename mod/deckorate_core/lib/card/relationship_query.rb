class Card
  # Query lookup table for relationship answers
  class RelationshipQuery < LookupQuery
    def lookup_class
      ::Relationship
    end

    def lookup_table
      "relationships"
    end
  end
end
::Relationship.const_get("ActiveRecord_Relation")
      .send :include, Card::LookupQuery::ActiveRecordExtension
