# -*- encoding : utf-8 -*-

class AddIsicValueTypes < Card::Migration
  def up
    %w[class group division section].each do |level|
      codename = "isic_#{level}_value"
      type_name = codename.camelize
      Card.create! name: type_name, type_id: Card::CardtypeID, codename: codename
      value_type = Card["ISIC+Industry #{level.capitalize}+value type"]
      value_type.update_attributes! content: "isic_#{level}"
    end
  end
end
