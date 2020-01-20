# -*- encoding : utf-8 -*-

class MakeRelationshipAnswersNumeric < Card::Migration
  def up
    Answer.where(metric_type_id: Card::RelationshipID).each do |a|
      a.refresh :numeric_value
    end
  end
end
