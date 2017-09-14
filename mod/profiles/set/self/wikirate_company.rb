def ids_related_to_research_group research_group
  research_group.projects.map(&:company_ids).flatten
end

format :json do
  view :core do
    Card.search(type_id: Card::WikirateCompanyID, return: :id)
        .each_with_object([]) do |id, comps|
      alias_card = Card.fetch(id, :aliases)
      comps << {
        id: id,
        name: Card.fetch_name(id),
        alias: (alias_card && alias_card.item_names || [])
      }
    end
  end
end
