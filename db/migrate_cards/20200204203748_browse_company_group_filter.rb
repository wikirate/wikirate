# -*- encoding : utf-8 -*-

class BrowseCompanyGroupFilter < Card::Migration
  def up
    ensure_code_card "browse_company_group_filter"
    ensure_card "Company Group+browse_company_group_filter",
                type: :search_type, content: {}
  end
end
