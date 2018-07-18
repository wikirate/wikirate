# -*- encoding : utf-8 -*-

class ClearTopicAndCompanyCounts < Card::Migration
  def up
    [Card::WikirateCompanyID, Card::WikirateTopicID].each do |id|
      Count.where(right_id: id).delete_all
    end
  end
end
