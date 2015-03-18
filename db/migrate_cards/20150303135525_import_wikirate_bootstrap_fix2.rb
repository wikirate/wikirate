# -*- encoding : utf-8 -*-

class ImportWikirateBootstrapFix2 < Card::Migration
  def up
    import_json "wikirate_bootstrap_fix2.json"
  end
end
