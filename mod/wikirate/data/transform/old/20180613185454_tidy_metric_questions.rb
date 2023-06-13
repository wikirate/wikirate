# -*- encoding : utf-8 -*-

class TidyMetricQuestions < Cardio::Migration::Transform
  def up
    Card.search left: { type_id: Card::MetricID }, right_id: Card::QuestionID do |card|
      next if card.type_id == Card::PlainTextID
      card.update!(
        db_content: ActionView::Base.new.strip_tags(card.db_content),
        type_id: Card::PlainTextID
      )
    end
  end
end
