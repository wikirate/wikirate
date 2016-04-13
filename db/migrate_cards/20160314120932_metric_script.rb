# -*- encoding : utf-8 -*-

class MetricScript < Card::Migration
  def up
    create_or_update 'script: metric',
                     type_id: Card::CoffeeScriptID,
                     codename: 'script_metric'
    if (card = Card.fetch 'metric+*type+*structure')
      card.delete!
    end
  end
end
