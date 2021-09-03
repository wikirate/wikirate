def ids_related_to_research_group research_group
  research_group.datasets.map(&:company_ids).flatten
end

format :html do
  view :core, template: :haml
end
