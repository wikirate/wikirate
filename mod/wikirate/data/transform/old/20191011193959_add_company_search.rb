# -*- encoding : utf-8 -*-

class AddCompanySearch < Cardio::Migration::Transform
  def up
    update_card "specification", name: "Specification"
    ensure_card %i[company_search right default],
                type_id: Card::SearchTypeID

    group_company_set = %i[company_group company type_plus_right]
    ensure_card (group_company_set + [:default]),
                type_id: Card::PointerID
    ensure_card (group_company_set + [:content_options]),
                type_id: Card::SearchTypeID,
                content: '{"type":"Company", "sort_by":"name"}'

    ensure_card %i[company_group featured],
                type_id: Card::PointerID
    ensure_card %i[company_group featured self content_options],
                type_id: Card::SearchTypeID,
                content: '{"type":"Company Group", "sort_by":"name"}'
  end
end
