# -*- encoding : utf-8 -*-

class ImportVigneshsFix < Card::Migration
  def up
    import_json "vigneshs_fix.json"
  end
end
