# -*- encoding : utf-8 -*-

class ImportWikirateCommonJs < Card::Migration
  def up
    import_cards 'wikirate_common_js.json'
  end
end
