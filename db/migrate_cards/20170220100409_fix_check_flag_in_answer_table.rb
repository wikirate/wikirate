# -*- encoding : utf-8 -*-

class FixCheckFlagInAnswerTable < Card::Migration
  def up
    ids = Card.search(type_id: Card::MetricValueID,
                      right_plus: "checked by",
                      return: :id)
    puts "updating flags for #{ids.size} answers ..."
    Answer.refresh ids, :checkers, :check_requester
  end
end
