# -*- encoding : utf-8 -*-

class BrowseCompanyGroupFilter < Cardio::Migration
  def up
    ensure_card "Company Group+browse_company_group_filter",
                type: :search_type, content: {}
  end
end
