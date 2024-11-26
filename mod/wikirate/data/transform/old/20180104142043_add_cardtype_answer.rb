# -*- encoding : utf-8 -*-

class AddCardtypeAnswer < Cardio::Migration::Transform
  def up
    type_to_answer left: { type_id: Card::MetricID },
                   right: { type_id: Card::CompanyID }
    type_to_answer left: { type_id: Card::AnswerID }, right: { type_id: Card::UserID }
  end

  def type_to_answer query
    ids = Card.search query.merge(return: :id)
    Card.where(id: ids).update_all type_id: Card::AnswerID
  end
end
