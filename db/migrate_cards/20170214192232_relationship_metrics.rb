# -*- encoding : utf-8 -*-

class RelationshipMetrics < Card::Migration
  def up
    ensure_card "Relationship",
                type: "Metric Type",
                codename: :relationship
    ensure_card "Inverse Relationship",
                type: "Metric Type",
                codename: :inverse_relationship
    ensure_card "Relationship Answer",
                type: "Cardtype",
                codename: :relationship_answer
    ensure_card "inverse", codename: :inverse
    Card::Cache.reset_all

    ensure_card [:value_options, :right, :default], type: "Pointer"
    ensure_card [:inverse, :right, :default], type: "Pointer"
  end
end
