# -*- encoding : utf-8 -*-

class ChangeCardKeyIndex < Cardio::Migration::Transform
  def up
    remove_index :cards, name: "cards_key_index"
    add_index :cards, ["key"], name: "cards_key_index", unique: true, length: 255
  end
end
