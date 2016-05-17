# -*- encoding : utf-8 -*-

class ImportNewTweaksAndBugfixes < Card::Migration
  def up
    import_json "new_tweaks_and_bugfixes.json"
  end
end
