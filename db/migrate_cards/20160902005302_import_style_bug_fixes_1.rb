# -*- encoding : utf-8 -*-

class ImportStyleBugFixes1 < Card::Migration
  def up
    import_cards 'style_bug_fixes_1.json'
  end
end
