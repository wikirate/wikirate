# -*- encoding : utf-8 -*-

class ImportFixCompanyCounts < Card::Migration
  def up
    import_json "fix_company_counts.json"
    Card.search(:type=>"company").each do |company|
      company.update_contribution_count
    end
  end
end
