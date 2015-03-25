# -*- encoding : utf-8 -*-

class ImportBootstrapFix4 < Card::Migration
  def up
    import_json "bootstrap_fix4.json"
  end
end
