# -*- encoding : utf-8 -*-

class CreatedAtForAnswers < Card::Migration
  def up
    Answer.where(created_at: nil).find_each do |a|
      begin
        next unless a.card && a.valid?
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
      rescue
        puts "problem updating answer: #{a}"
      end
    end
  end
end