# -*- encoding : utf-8 -*-

class RelationshipMetrics < Card::Migration
  def up
    Card.create! name: "Relationship", type: "Metric Type"
    Card.create! name: "Inverse Relationship", type: "Metric Type"
    Card.create! name: "Relationship Answer", type: "Cardtype"
    Card.create! name: "Metric+inverse+*default", type: "Pointer"
    Card.create! name: "Metric Title+inverse+*default", type: "Pointer"
  end
end
