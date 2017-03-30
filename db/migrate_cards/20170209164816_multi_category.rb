# -*- encoding : utf-8 -*-

class MultiCategory < Card::Migration
  def up
    ensure_card "Multi-Category", codename: "multi_category"
    ensure_card "Category", codename: "category"
    ensure_card "Free Text", codename: "free_text"
    Card["Metric+value type+*type plus right+*options"]
      .insert_item! 3, "Multi-Category"
  end
end
