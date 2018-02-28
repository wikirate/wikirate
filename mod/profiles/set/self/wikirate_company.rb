def ids_related_to_research_group research_group
  research_group.projects.map(&:company_ids).flatten
end

format :json do
  view :core do
    Card.search(type_id: Card::WikirateCompanyID, return: :id)
        .each_with_object([]) do |id, comps|
      alias_card = Card.fetch(id, :aliases)
      oc_card = Card.fetch(id, :open_corporates)
      wikipedia_card = Card.quick_fetch(id, :wikipedia)
      comps << {
        id: id,
        name: Card.fetch_name(id),
        alias: (alias_card&.item_names || []),
        oc_id: oc_card&.company_number,
        oc_jurisdiction_code: oc_card&.jurisdiction_code,
        wikipedia_title: wikipedia_card&.content
      }
    end
  end
end
