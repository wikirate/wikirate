# -*- encoding : utf-8 -*-

class StyleWikirateBootstrapTable < Card::Migration
  def up
    create_or_update name: 'style wikirate bootstrap table',
                     type_id: 3819,
                     codename: 'style_wikirate_bootstrap_table'
  end
end
