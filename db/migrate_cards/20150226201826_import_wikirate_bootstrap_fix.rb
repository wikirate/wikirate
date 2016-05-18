# -*- encoding : utf-8 -*-

class ImportWikirateBootstrapFix < Card::Migration
  def up
    import_json "wikirate_bootstrap_fix.json"
  end
end
