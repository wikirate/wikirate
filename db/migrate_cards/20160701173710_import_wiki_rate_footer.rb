# -*- encoding : utf-8 -*-

class ImportWikiRateFooter < Card::Migration
  def up
    import_cards 'wiki_rate_footer.json'
  end
end
