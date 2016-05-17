# -*- encoding : utf-8 -*-

class MetricValueType < Card::Migration
  def up
    create_or_update(
      "Value Type",
      type_id: Card::PointerID,
      subcards: {
        "+*input" => "select",
        "+*options" => "[[Number]]\n[[Category]]\n[[Money]]\n[[Free Text]]"
      }
    )
    create_or_update "Money"
    create_or_update "Number"
    create_or_update "Category"
  end
end