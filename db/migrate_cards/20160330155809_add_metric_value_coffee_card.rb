# -*- encoding : utf-8 -*-

class AddMetricValueCoffeeCard < Card::Migration
  def up
    create_card name: 'script: metric value', codename: 'script_metric_value',
                                        type_id: Card::CoffeeScriptID
    if (card = Card['metric value+*type+*structure'])
      card.delete!
    end
  end
end
