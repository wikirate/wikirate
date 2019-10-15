# -*- encoding : utf-8 -*-

class AddCompanySearch < Card::Migration
  def up
    ensure_code_card "Company Search"
    update_card "specification", name: "Specification"
    ensure_card %i[company_search right default],
                type_id: Card::SearchTypeID

    group_company_set = %i[company_group wikirate_company type_plus_right]
    ensure_card (group_company_set + [:default]),
                type_id: Card::PointerID
    ensure_card (group_company_set + [:content_options]),
                type_id: Card::SearchTypeID,
                content: '{"type":"Company", "sort":"name"}'
  end
end
