# -*- encoding : utf-8 -*-

class SumToTotal < Cardio::Migration::Transform
  def up
    Card.search(right_id: Card::FormulaID, left: { type_id:  Card::MetricID },
                content: ["match", "Sum"]).each do |card|
      next unless card.content.include? "Sum["
      card.update_column :db_content, card.content.gsub("Sum[", "Total[")
    end
  end
end
