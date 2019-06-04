# -*- encoding : utf-8 -*-

class InitInverseIdsInRelationshipTable < Card::Migration
  def up
    Relationship.pluck(:metric_id).uniq.each do |mid|
      inverse_id = Card.fetch(mid).inverse_card.id
      Relationship.where(metric_id: mid).update_all inverse_metric_id: inverse_id
    end
  end
end
