# -*- encoding : utf-8 -*-

class CreatedAtForAnswers < Card::Migration
  def up
    Answer.where(created_at: nil).each do |a|
      a.update_attributes! created_at: a.card.created_at
    end
  end
end
