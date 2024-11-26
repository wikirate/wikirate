# -*- encoding : utf-8 -*-

class FixCheckersInAnswersTable < Cardio::Migration::Transform
  def up
    Card.where(right_id: Card::CheckedByID).find_each do |checked_by|
      answer_card = checked_by.left
      next unless answer_card&.type_id == Card::AnswerID
      checked_by.include_set_modules
      next unless checked_by.checked?
      checker_list = checked_by.checkers.join ", "
      Answer.where(answer_id: answer_card.id).update_all checkers: checker_list
    end
  end
end
