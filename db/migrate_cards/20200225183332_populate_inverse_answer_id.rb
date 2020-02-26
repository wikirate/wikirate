# -*- encoding : utf-8 -*-

class PopulateInverseAnswerId < Card::Migration
  def up
    Relationship.find_each do |rel|
      rel.refresh :inverse_answer_id
    end
  end
end
