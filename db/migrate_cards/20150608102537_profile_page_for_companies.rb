# -*- encoding : utf-8 -*-

class ProfilePageForCompanies < Card::Migration
  def up
    # ['contributed_metrics','contributed_claims','contributed_sources','contributed_campaigns','contributed_analysis'].each do |name|
    #   card = Card.fetch name
    #   card.update_attributes! :codename=>name
    # end
    Card.create! name: "contributed metrics", codename: "contributed_metrics"
    Card.create! name: "contributed claims", codename: "contributed_claims"
    Card.create! name: "contributed sources", codename: "contributed_sources"
    Card.create! name: "contributed campaigns", codename: "contributed_campaigns"
    Card.create! name: "contributed analysis", codename: "contributed_analysis"
    import_json "profile_page_for_companies.json"
  end
end
