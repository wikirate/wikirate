# -*- encoding : utf-8 -*-

class ImportProfilePageFix2 < Card::Migration
  def up
    import_json "profile_page_fix_2.json"
    Card.fetch('my contributions+*right+*structure').delete
  end
end
