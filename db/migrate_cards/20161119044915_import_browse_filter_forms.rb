# -*- encoding : utf-8 -*-

class ImportBrowseFilterForms < Card::Migration
  def up
    import_cards 'browse_filter_forms.json'
  end
end
