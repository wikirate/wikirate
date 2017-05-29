# -*- encoding : utf-8 -*-

class InitializeCheckFlagInAnswerTable < Card::Migration
  def up
    clear_empty_checks
    answer_ids = Card.search(type_id: Card::MetricValueID,
                             right_plus: "checked by",
                             return: :id)
    puts "updating #{answer_ids.size} answers"
    Answer.refresh answer_ids, :checkers, :check_requester
  end

  def clear_empty_checks
    empty_check_ids = Card.search(left: { type_id: Card::MetricValueID },
                                  right: "checked by",
                                  content: "",
                                  return: :id)
    puts "deleting #{empty_check_ids.size} empty checked_by cards"
    Card.delete empty_check_ids
  end
end
