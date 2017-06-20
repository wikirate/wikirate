# -*- encoding : utf-8 -*-

class AddJurisdiction < Card::Migration
  def up
    ensure_card "Jurisdiction",
                type_id: Card::CardtypeID, codename: "jurisdiction"

    ensure_card "Jurisdiction+*type+*default",
                type_id: Card::PhraseID

    Card::Cache.reset_all


  end

  def import_jurisdictions
    jurisdictions_from_open_corporates.each do |_key, data|
      ensure_card data["full_name"], codename: data["code"]
    end
  end

  # json response from OC api:
  # {"api_version"=>"0.4",
  #  "results"=>
  #   {"jurisdictions"=>
  #     [ {"jurisdiction"=>{"code"=>"ad", "name"=>"Andorra",
  #                         "country"=>"Andorra", "full_name"=>"Andorra"}},
  #       ...
  #     ] }}
  def jurisdiction_from_open_corporates
    json = JSON.parse open("https://api.opencorporates.com/v0.4/jurisdictions").read
    json["results"]["jurisdictions"]
  end
end
