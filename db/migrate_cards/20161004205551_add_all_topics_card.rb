# -*- encoding : utf-8 -*-

class AddAllTopicsCard < Card::Migration
  def up
    ensure_card "all topics", codename: "all_topics",
                              type_id: Card::SearchTypeID
  end
end
