# -*- encoding : utf-8 -*-

class RelationshipMetrics < Card::Migration
  def up
    Card.create! name: "Relationship",
                 type: "Metric Type",
                 codename: :relationship
    Card.create! name: "Inverse Relationship",
                 type: "Metric Type",
                 codename: :inverse_relationship
    Card.create! name: "Relationship Answer",
                 type: "Cardtype",
                 codename: :relationship_answer
    Card.create! name: "Metric+inverse+*default", type: "Pointer"
    Card.create! name: "Metric Title+inverse+*default", type: "Pointer"
  end
end
