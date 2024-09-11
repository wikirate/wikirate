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

  view :metric_tab do
    field_nest :metric, view: :filtered_content
  end

  view :research_group_tab do
    field_nest :research_group, view: :filtered_content
  end

  view :dataset_tab do
    field_nest :dataset, view: :filtered_content
  end

  view :details_tab_left do
    field_nest :general_overview, view: :titled
  end

  view :details_tab_right do
    field_nest :subtopic, view: :titled, title: "Subtopics", items: { view: :bar }
  end
end
