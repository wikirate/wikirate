# -*- encoding : utf-8 -*-

class StyleWikirateLayout < Card::Migration
  def up
    create_or_update name: 'style wikirate layout',
                     type_id: 3819,
                     codename: 'style_wikirate_layout'
  end
end
