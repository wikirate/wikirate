# -*- encoding : utf-8 -*-

class ImportTweaksBugFixes < Card::Migration
  def up
    import_json "tweaks_bug_fixes.json"
    
  end
end
