# -*- encoding : utf-8 -*-

class ImportCompanyContributionLink < Card::Migration
  def up
    import_json "company_contribution_link.json"
    
  end
end
