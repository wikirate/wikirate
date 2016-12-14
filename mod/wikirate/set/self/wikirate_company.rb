def ids_related_to_research_group research_group
  research_group.projects.map(&:company_ids).flatten
end
