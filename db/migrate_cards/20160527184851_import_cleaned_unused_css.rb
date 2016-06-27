# -*- encoding : utf-8 -*-

class ImportCleanedUnusedCss < Card::Migration
  def up
    import_cards 'cleaned_unused_css.json'
  end
end
