# -*- encoding : utf-8 -*-

class ImportWikirateBootstraFix3 < Card::Migration
  def up
    import_json "wikirate_bootstrap_fix3.json"
  end
end
