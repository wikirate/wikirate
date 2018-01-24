# -*- encoding : utf-8 -*-

class CreatedAtForAnswers < Card::Migration
  def up
    Answer.where(created_at: nil).each do |a|
      next unless a.card
      if a.card.type_id == Card::MetricValueID
        if a.card.researched?
          a.update_attributes! created_at: a.card.created_at
        else
          a.update_attributes! created_at: a.card.created_at, answer_id: nil
          a.card.delete!
        end
      else
        a.destroy!
      end
    end
  end
end