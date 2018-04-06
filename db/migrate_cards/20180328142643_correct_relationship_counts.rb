# -*- encoding : utf-8 -*-

class CorrectRelationshipCounts < Card::Migration
  disable_ddl_transaction!

  def up
    # Card.search(type_id: Card::RelationshipAnswerID).each do |card|
    #   card.update_counts!
    # end
  end
end
