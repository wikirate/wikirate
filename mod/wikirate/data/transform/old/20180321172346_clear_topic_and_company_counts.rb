# -*- encoding : utf-8 -*-

class ClearTopicAndCompanyCounts < Cardio::Migration::Transform
  def up
    [Card::WikirateCompanyID, Card::TopicID].each do |id|
      Card::Count.where(right_id: id).delete_all
    end
  end
end
