# -*- encoding : utf-8 -*-

class CreatedAtForAnswers < Card::Migration
  def up
    Answer.where(created_at: nil).each do |a|
      if a.card.type_id == Card::MetricValueID
        a.update_attributes! created_at: a.card.created_at
      else
        a.card.delete!
        a.destroy!
      end
    end
  end
end
