# -*- encoding : utf-8 -*-

class ImportMissingImageCodename < Card::Migration
  def up
    Card.create! name: "missing_image_card", codename: "missing_image_card"
  end
end
