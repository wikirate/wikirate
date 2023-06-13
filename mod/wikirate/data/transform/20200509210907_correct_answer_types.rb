# -*- encoding : utf-8 -*-

class CorrectAnswerTypes < Cardio::Migration::Transform
  def up
    update_type :answer, Card::MetricAnswerID
    update_type :relationship, Card::RelationshipAnswerID
  end

  def update_type type, type_id
    Card.connection.update(
      "UPDATE cards set type_id = #{type_id} " \
      "WHERE exists (select * from #{type}s where #{type}_id = cards.id)"
    )
  end
end
