# -*- encoding : utf-8 -*-

class ImportWagnBootstrapUpdates < Card::Migration
  def up
    import_json "wagn_bootstrap_updates.json"
    
  end
end
