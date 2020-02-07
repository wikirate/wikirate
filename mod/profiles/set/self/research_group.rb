include_set Abstract::OrganizerQueries

format :html do
  view :titled_content do
    [field_nest(:description), render_add_button, research_groups]
  end

  def research_groups
    field_nest :browse_research_group_filter, view: :filtered_content
  end
end
