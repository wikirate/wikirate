# -*- encoding : utf-8 -*-

class YearlyVariable < Card::Migration
  def up
    create_card name: "Yearly Variable", codename: "yearly_variable",
                type_id: Card::CardtypeID
    create_card name: "Yearly Value", codename: "yearly_value",
                type_id: Card::CardtypeID
    create_card name: "Yearly Answer", codename: "yearly_answer",
                type_id: Card::CardtypeID
  end
end
