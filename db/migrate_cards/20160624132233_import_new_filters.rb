# -*- encoding : utf-8 -*-

class ImportNewFilters < Card::Migration
  def up
    import_cards 'new_filters.json'
  end
end
