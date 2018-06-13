# -*- encoding : utf-8 -*-

class TidyMetricQuestions < Card::Migration
  def up
    merge_cards "Metric+Score+*type plus right+*structure"
    Card.search left: { type_id: Card::MetricID }, right_id: Card::QuestionID do |card|
      card.update_attributes! db_content: ActionView::Base.new.strip_tags(card.db_content),
                              type_id: Card::PlainTextID
    end
  end
end
