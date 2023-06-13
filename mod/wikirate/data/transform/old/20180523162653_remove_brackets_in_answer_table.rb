# -*- encoding : utf-8 -*-

class RemoveBracketsInAnswerTable < Cardio::Migration::Transform  def up
    %w[Yes No Unknown].each do |val|
      Answer.where(value: "[[#{val}]]").update_all(value: val)
    end
  end
end
