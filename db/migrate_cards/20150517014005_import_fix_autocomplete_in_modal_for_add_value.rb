# -*- encoding : utf-8 -*-

class ImportFixAutocompleteInModalForAddValue < Card::Migration
  def up
    import_json "fix_autocomplete_in_modal_for_add_value.json"
    
  end
end
