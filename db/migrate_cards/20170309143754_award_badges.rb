# -*- encoding : utf-8 -*-

class AwardBadges < Card::Migration
  def up
    Card.search(type_id: Card::UserID).each do |user|
      update :metric_type, :create,
    end
  end
end
