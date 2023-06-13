# -*- encoding : utf-8 -*-

class RecalculateAnswers < Cardio::Migration::Transform
  def up
    Card.search type_id: Card::MetricID do |metric|
      next unless (formula_card = metric.try(:formula_card))
      puts "updating answers for #{metric.name}"
      formula_card.update_calculated_answers
    end
  end
end
