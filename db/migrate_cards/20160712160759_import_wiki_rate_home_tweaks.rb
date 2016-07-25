# -*- encoding : utf-8 -*-

class ImportWikiRateHomeTweaks < Card::Migration
  def up
    import_cards "wiki_rate_home_tweaks.json"
  end
end
