# -*- encoding : utf-8 -*-

class AddRelatedCompany < Card::Migration
  def up
    ensure_trait "related company", "related_company",
                 default: { type: :pointer },
                 input: "autocomplete",
                 options: { type: :search_type, content: '{ "type":"company" }' }
  end
end
