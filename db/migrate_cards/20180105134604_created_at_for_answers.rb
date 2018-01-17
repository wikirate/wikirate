# -*- encoding : utf-8 -*-

class CreatedAtForAnswers < Card::Migration
  def up
    Answer.where(created_at: nil).each do |a|
      if a.card.type_id != Card::MetricValueID
        a.card.update_attributes! type_id: Card::MetricValueID
      end
      a.update_attributes! created_at: a.card.created_at
    end
  end
end
