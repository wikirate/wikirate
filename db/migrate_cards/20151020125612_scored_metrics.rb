# -*- encoding : utf-8 -*-

class ScoredMetrics < Card::Migration
  def up
    create_card! name: 'Scored metric', codename: 'scored_metric'
    create_card! name: 'formula', codename: 'formula'
    create_card! name: 'Scored metric+*type+*structure',
                 content: "{{+formula}}"
  end
end
