# -*- encoding : utf-8 -*-

class ImportSourceFilterCss < Card::Migration
  def up
    import_cards 'source_filter_css.json'
  end
end
