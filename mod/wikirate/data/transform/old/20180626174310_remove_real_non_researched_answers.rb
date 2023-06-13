# -*- encoding : utf-8 -*-

class RemoveRealNonResearchedAnswers < Cardio::Migration::Transform
  def up
    calculated_ids = [Card::WikiRatingID, Card::FormulaID, Card::ScoreID,
                      Card::DescendantID]

    Answer.where(answer_id: nil, metric_type_id: calculated_ids, overridden_value: nil)
          .find_each do |answer|
      next unless (answer_card = Card[answer.record_name, answer.year.to_s])
      children = answer_card&.children || []
      if children&.empty? || only_value_child?(children)
        answer_card.delete!
      else
        answer.update! answer_id: answer_card.id
      end
    end
  end

  def only_value_child? children
    (children.one? && children.first.right.codename.to_sym == :value)
  end
end
