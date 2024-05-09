format :html do
  view :unknown do
    _render_link
  end

  mini_bar_cols 7, 5

  before :content_formgroups do
    # voo.edit_structure = %i[image subtopic general_overview]
    voo.edit_structure = %i[image general_overview]
  end

  def tab_list
    %i[details metric dataset research_group]
  end

  def tab_options
    { research_group: { label: "Research Groups" } }
  end

  view :details_tab do
    render_details
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content, items: { view: :bar }
  end

  view :research_group_tab do
    field_nest :research_group, items: { view: :bar }
  end

  view :dataset_tab do
    field_nest :dataset, items: { view: :bar }
  end

  view :details do
    [
      field_nest(:subtopic, view: :titled, title: "Subtopics", items: { view: :bar }),
      field_nest(:general_overview, view: :titled)
    ]
  end
end
