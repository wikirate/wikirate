# -*- encoding : utf-8 -*-

class ImportCompanyFilterSearch < Card::Migration
  def up
    import_cards 'company_filter_search.json'
  end
end
