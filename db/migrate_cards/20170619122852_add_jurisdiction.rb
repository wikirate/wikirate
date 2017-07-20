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
                 options: { type: :search_type, content: '{ "type" : "Jurisdiction" }' }

    ensure_trait "Country of Incorporation", :incorporation,
                 default: { type: :pointer },
                 input: "select",
                 options: { type: :search_type, content: '{ "type" : "Jurisdiction" }' }

    Card::Cache.reset_all
    import_jurisdictions
  end

  def import_jurisdictions
    OpenCorporates::API.fetch_jurisdictions.each do |data|
      ensure_card data["full_name"],
                  codename: "oc_#{data['code']}",
                  type: :jurisdiction
    end
  end
end
