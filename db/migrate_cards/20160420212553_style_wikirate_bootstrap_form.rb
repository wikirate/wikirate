# -*- encoding : utf-8 -*-

class StyleWikirateBootstrapForm < Card::Migration
  def up
    create_or_update name: 'style: wikirate bootstrap form',
                     type_id: 3819,
                     codename: 'style_wikirate_bootstrap_form'
  end
end
