# -*- encoding : utf-8 -*-

class MetricValueType < Card::Migration
  def up
    create_or_update 'Value Type', type_id: Card::PointerID,
                     subcards: {
                         '+*input' => 'select',
                         '+*options' => "[[Number]]\n[[Categorical]]\n[[Monetary]]"
                     }
    create_or_update 'Monetary'
    create_or_update 'Number'
    create_or_update 'Categorical'
  end
end