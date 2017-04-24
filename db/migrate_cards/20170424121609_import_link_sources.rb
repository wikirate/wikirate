# -*- encoding : utf-8 -*-

class ImportLinkSources < Card::Migration
  def up
    import_cards 'link_sources.json'
  end
end
