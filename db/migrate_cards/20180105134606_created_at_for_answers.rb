# -*- encoding : utf-8 -*-

class CreatedAtForAnswers < Card::Migration
  def up
    # Answer.where(created_at: nil).find_each do |a|
    #   next unless a.card
    #   if a.card.type_id == Card::MetricValueID
    #     begin
    #       if a.card.researched?
    #         a.update_attributes! created_at: a.card.created_at
    #       else
    #         a.created_at = a.card.created_at
    #         a.answer_id = nil
    #         a.card.delete!
    #         a.save!
    #         puts "successfully migrated calculated answer: #{a.id}"
    #       end
    #     rescue
    #       puts "problem migrating answer: #{a.id} "
    #     end
    #   else
    #     a.destroy!
    #   end
    # end
  end
end
