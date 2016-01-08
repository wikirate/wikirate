# -*- encoding : utf-8 -*-

class ImportTweaksAndBugfixes < Card::Migration
  def up
    import_json "tweaks_and_bugfixes.json"
    
  end
end
