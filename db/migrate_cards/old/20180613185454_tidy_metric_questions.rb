# -*- encoding : utf-8 -*-

class TidyMetricQuestions < Card::Migration
  def up
    merge_cards ["Metric+Score+*type plus right+*structure",
                 "Metric+question+*type plus right+*default"]
    Card.search left: { type_id: Card::MetricID }, right_id: Card::QuestionID do |card|
      next if card.type_id == Card::PlainTextID
      card.update!(
        db_content: ActionView::Base.new.strip_tags(card.db_content),
        type_id: Card::PlainTextID
      )
    end
  end
end
