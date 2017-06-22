# -*- encoding : utf-8 -*-

class AddJurisdiction < Card::Migration
  def up
    ensure_card "Jurisdiction",
                type_id: Card::CardtypeID, codename: "jurisdiction"

    ensure_card "Jurisdiction+*type+*input",
                content: "text field"


    ensure_card "OpenCorporates", codename: "open_corporates"
    ensure_card ["OpenCorporates", :right, :default], type: :phrase
    ensure_trait "Country of Headquarters", :headquarters,
                 default: { type: :pointer },
                 input: "select",
                 options: "Jurisdiction"

    ensure_trait "Country of Incorporation", :incorporation,
                 default: { type: :pointer },
                 input: "select",
                 options: "Jurisdiction"


    import_jurisdictions
  end

  def import_jurisdictions
    jurisdictions_from_open_corporates.each do |jur|
      data = jur["jurisdiction"]
      ensure_card data["full_name"], codename: data["code"],
                  type: :jurisdiction
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
  def jurisdictions_from_open_corporates
    json = OpenCorporates::API.fetch :jurisdictions
    json["results"]["jurisdictions"]
  end
end
