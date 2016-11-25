# -*- encoding : utf-8 -*-

class StyleWikirateProgressBar < Card::Migration
  def up
    create_or_update name: 'style: wikirate progress bar',
                     type_id: Card::ScssID,
                     codename: 'style_wikirate_progress_bar'
  end
end
