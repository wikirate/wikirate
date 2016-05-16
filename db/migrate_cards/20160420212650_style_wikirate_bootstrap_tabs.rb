# -*- encoding : utf-8 -*-

class StyleWikirateBootstrapTabs < Card::Migration
  def up
    create_or_update name: 'style wikirate bootstrap tabs',
                     type_id: 3819,
                     codename: 'style_wikirate_bootstrap_tabs'
  end
end
