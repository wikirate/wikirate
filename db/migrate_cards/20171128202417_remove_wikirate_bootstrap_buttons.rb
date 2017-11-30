# -*- encoding : utf-8 -*-

class RemoveWikirateBootstrapButtons < Card::Migration
  def up
    Card["customized_classic_skin"].drop_item! :style_wikirate_bootstrap_buttons
    delete_code_card :style_wikirate_bootstrap_buttons
  end
end
