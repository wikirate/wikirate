# -*- encoding : utf-8 -*-

class FixCalculatedAnswers < Cardio::Migration::Transform
  def up
    Answer.where(metric_type_id: [Card::FormulaID, Card::ScoreID, Card::WikiRatingID])
          .update_all(answer_id: nil)
  end
end
